variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name prefix for resources"
  type        = string
  default     = "order-notifier"
}

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "mydatabase"
}

variable "db_username" {
  description = "Postgres master username"
  type        = string
  default     = "adminuser"
}
