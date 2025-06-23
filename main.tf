terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "bonmoja-tf-state"
    key            = "bonmoja/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "bonmoja-tf-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

# -------------------------------------------------------------------------------------------------
# Core Networking
# -------------------------------------------------------------------------------------------------
module "vpc" {
  source       = "./modules/vpc"
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
  aws_region   = var.aws_region
}

# -------------------------------------------------------------------------------------------------
# Application Infrastructure
# -------------------------------------------------------------------------------------------------
module "ecs" {
  source = "./modules/ecs"

  project_name          = var.project_name
  aws_region            = var.aws_region
  vpc_id                = module.vpc.vpc_id
  public_subnets        = module.vpc.public_subnets
  private_subnets       = module.vpc.private_subnets
  ecs_task_iam_role_arn = aws_iam_role.ecs_task_role.arn
  ecs_sg_id             = module.ecs.ecs_service_sg_id
  ecs_image_uri         = var.ecs_image_uri
}

# -------------------------------------------------------------------------------------------------
# Data Storage
# -------------------------------------------------------------------------------------------------
module "rds" {
  source = "./modules/rds"

  project_name    = var.project_name
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  db_username     = var.db_username
  db_password     = var.db_password
  ecs_sg_id       = module.ecs.ecs_service_sg_id
}

resource "aws_dynamodb_table" "metadata_storage" {
  name         = "${var.project_name}-metadata"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Project = var.project_name
  }
}

# -------------------------------------------------------------------------------------------------
# Decoupled Messaging
# -------------------------------------------------------------------------------------------------
resource "aws_sqs_queue" "message_queue" {
  name = "${var.project_name}-message-queue"
  tags = {
    Project = var.project_name
  }
}

resource "aws_sns_topic" "notification_topic" {
  name = "${var.project_name}-notification-topic"
  tags = {
    Project = var.project_name
  }
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.notification_topic.arn
  protocol  = "email"
  endpoint  = var.sns_email_endpoint # Now parameterized
}

# -------------------------------------------------------------------------------------------------
# Security & IAM
# -------------------------------------------------------------------------------------------------
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.project_name}-ecs-task-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecs_task_policy" {
  name = "${var.project_name}-ecs-task-policy"
  role = aws_iam_role.ecs_task_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage"
        ],
        Effect   = "Allow",
        Resource = aws_sqs_queue.message_queue.arn
      },
      {
        Action   = "sns:Publish",
        Effect   = "Allow",
        Resource = aws_sns_topic.notification_topic.arn
      },
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ],
        Effect   = "Allow",
        Resource = aws_dynamodb_table.metadata_storage.arn
      }
      # A policy to access secrets from AWS Secrets Manager would go here
    ]
  })
}

# -------------------------------------------------------------------------------------------------
# Monitoring & Alerting
# -------------------------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "${var.project_name}-rds-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300" # 5 minutes
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This alarm fires if RDS CPU utilization is >= 80% for 5 minutes."
  dimensions = {
    DBInstanceIdentifier = module.rds.db_instance_id
  }
  alarm_actions = [aws_sns_topic.notification_topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "sqs_depth" {
  alarm_name          = "${var.project_name}-sqs-depth-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2" # for 10 minutes total
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = "300" # 5 minute periods
  statistic           = "Average"
  threshold           = "100"
  alarm_description   = "This alarm fires if the SQS queue depth is >= 100 for 10 minutes."
  dimensions = {
    QueueName = aws_sqs_queue.message_queue.name
  }
  alarm_actions = [aws_sns_topic.notification_topic.arn]
}

