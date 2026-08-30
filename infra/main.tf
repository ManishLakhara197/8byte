module "network" {
  source = "./modules/network"

  project_name      = var.project_name
  environment       = var.environment
  name_prefix       = var.name_prefix
  vpc_cidr          = var.vpc_cidr
  availability_zones = var.availability_zones
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "security" {
  source = "./modules/security"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.network.vpc_id
  app_port     = var.app_port
}

module "loadbalancer" {
  source = "./modules/loadbalancer"

  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.network.vpc_id
  public_subnets    = module.network.public_subnet_ids
  security_group_id = module.security.alb_security_group_id
  app_port          = var.app_port
}

module "database" {
  source = "./modules/database"

  project_name         = var.project_name
  environment          = var.environment
  vpc_id               = module.network.vpc_id
  subnet_ids           = module.network.private_subnet_ids
  app_security_group_id = module.security.app_security_group_id
  db_instance_class    = var.db_instance_class
  db_allocated_storage = var.db_allocated_storage
  db_engine_version    = var.db_engine_version
  db_multi_az          = var.db_multi_az
  db_password          = var.db_password
}

module "compute" {
  source = "./modules/compute"

  project_name            = var.project_name
  environment             = var.environment
  vpc_id                  = module.network.vpc_id
  public_subnets          = module.network.public_subnet_ids
  private_subnets         = module.network.private_subnet_ids
  app_security_group_id   = module.security.app_security_group_id
  alb_security_group_id   = module.security.alb_security_group_id
  target_group_arn       = module.loadbalancer.target_group_arn
  db_secret_arn          = module.database.db_secret_arn
  container_image        = var.container_image
  app_cpu                = var.app_cpu
  app_memory             = var.app_memory
  app_port               = var.app_port
  min_capacity           = var.min_capacity
  max_capacity           = var.max_capacity
  aws_account_id         = var.aws_account_id
  region                 = var.region
}
