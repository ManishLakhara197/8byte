output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.network.vpc_id
}

output "subnet_ids" {
  description = "Public and private subnet IDs"
  value = {
    public  = module.network.public_subnet_ids
    private = module.network.private_subnet_ids
  }
}

output "alb_dns_name" {
  description = "DNS name of the application load balancer"
  value       = module.loadbalancer.alb_dns_name
}

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = module.database.db_endpoint
  sensitive   = true
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.compute.cluster_name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = module.compute.service_name
}

output "security_group_ids" {
  description = "Security group IDs for the application stack"
  value = {
    alb = module.security.alb_security_group_id
    app = module.security.app_security_group_id
    rds = module.database.security_group_id
  }
}
