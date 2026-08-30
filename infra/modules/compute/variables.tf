variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "app_security_group_id" {
  type = string
}

variable "alb_security_group_id" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "db_secret_arn" {
  type = string
}

variable "container_image" {
  type = string
}

variable "app_cpu" {
  type = number
}

variable "app_memory" {
  type = number
}

variable "app_port" {
  type = number
}

variable "min_capacity" {
  type = number
}

variable "max_capacity" {
  type = number
}

variable "aws_account_id" {
  type = string
}

variable "region" {
  type = string
}
