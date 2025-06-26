variable "project_name" {
  description = "A name for the project to prefix resources."
  type        = string
}

variable "project_prefix" {
  description = "Short, lowercase prefix for resource names."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC to deploy the RDS instance in."
  type        = string
}

variable "private_subnets" {
  description = "A list of private subnet IDs for the RDS instance."
  type        = list(string)
}

variable "db_username" {
  description = "Username for the RDS database."
  type        = string
}

variable "db_password" {
  description = "Password for the RDS database."
  type        = string
  sensitive   = true
}

variable "ecs_sg_id" {
  description = "The ID of the ECS service security group to allow connections from."
  type        = string
}