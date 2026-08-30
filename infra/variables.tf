variable "region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Project name used in naming resources"
  type        = string
  default     = "eightbytes"
}

variable "name_prefix" {
  description = "Prefix to add to resource names"
  type        = string
  default     = "eightbytes"
}

variable "availability_zones" {
  description = "Availability zones for the VPC and resources"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.10.1.0/24", "10.10.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.10.11.0/24", "10.10.12.0/24"]
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Storage to allocate for the RDS instance in GB"
  type        = number
  default     = 20
}

variable "db_engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "16.3"
}

variable "db_multi_az" {
  description = "Enable multi-AZ for RDS"
  type        = bool
  default     = false
}

variable "app_cpu" {
  description = "ECS task vCPU value"
  type        = number
  default     = 256
}

variable "app_memory" {
  description = "ECS task memory in MiB"
  type        = number
  default     = 512
}

variable "app_port" {
  description = "Port the application container listens on"
  type        = number
  default     = 3000
}

variable "min_capacity" {
  description = "Minimum ECS task count"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum ECS task count"
  type        = number
  default     = 2
}

variable "container_image" {
  description = "Container image for the ECS task"
  type        = string
  default     = "123456789012.dkr.ecr.us-east-1.amazonaws.com/example-app:latest"
}

variable "aws_account_id" {
  description = "AWS account ID for ECR and other resources"
  type        = string
  default     = "123456789012"
}

variable "db_password" {
  description = "Database password for the Postgres instance. Supply via tfvars or a secrets manager."
  type        = string
  default     = "ChangeMePassword123!"
  sensitive   = true
}
