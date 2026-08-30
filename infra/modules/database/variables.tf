variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "app_security_group_id" {
  type = string
}

variable "db_instance_class" {
  type = string
}

variable "db_allocated_storage" {
  type = number
}

variable "db_engine_version" {
  type = string
}

variable "db_multi_az" {
  type = bool
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "vpc_id" {
  type = string
}
