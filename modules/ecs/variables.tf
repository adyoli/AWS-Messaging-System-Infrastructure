variable "project_name" {
  description = "A name for the project to prefix resources."
  type        = string
}

variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC to deploy resources in."
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs."
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet IDs."
  type        = list(string)
}

variable "ecs_task_iam_role_arn" {
  description = "ARN of the IAM role for ECS tasks."
  type        = string
}

variable "ecs_sg_id" {
  description = "The ID of the ECS service security group to allow connections from."
  type        = string
}

variable "ecs_image_uri" {
  description = "The URI of the Docker image to use for the ECS service."
  type        = string
}