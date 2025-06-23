variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
}

variable "project_name" {
  description = "A name for the project to prefix resources."
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "db_username" {
  description = "Username for the RDS database."
  type        = string
}

variable "db_password" {
  description = "Password for the RDS database. Should be passed as an environment variable."
  type        = string
  sensitive   = true
}

variable "sns_email_endpoint" {
  description = "Email address for SNS topic subscription."
  type        = string
}

variable "ecs_image_uri" {
  description = "The URI of the Docker image to use for the ECS service."
  type        = string
}