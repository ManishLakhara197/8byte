output "db_endpoint" {
  value = aws_db_instance.this.address
}

output "db_secret_arn" {
  value = "arn:aws:secretsmanager:region:account:secret:placeholder"
}

output "security_group_id" {
  value = aws_security_group.rds.id
}
