resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-${var.environment}-db-subnets"
  subnet_ids = var.subnet_ids
}

resource "aws_security_group" "rds" {
  name        = "${var.project_name}-${var.environment}-rds-sg"
  description = "Allow PostgreSQL from the application security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "this" {
  identifier              = "${var.project_name}-${var.environment}-db"
  engine                  = "postgres"
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  db_name                 = "appdb"
  username                = "postgres"
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  multi_az                = var.db_multi_az
  publicly_accessible     = false
  skip_final_snapshot     = true
  backup_retention_period = 7
  storage_encrypted       = true

  tags = {
    Name = "${var.project_name}-${var.environment}-db"
  }
}
