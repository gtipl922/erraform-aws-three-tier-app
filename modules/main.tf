# main.tf
module "vpc" {
  source = "./vpc"

  project_name            = var.project_name
  vpc_cidr               = "10.0.0.0/16"
  public_subnet_cidrs    = ["10.0.1.0/24", "10.0.2.0/24"]
  private_app_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
  private_db_subnet_cidrs = ["10.0.5.0/24", "10.0.6.0/24"]
  availability_zones     = ["us-east-1a", "us-east-1b"]
}

module "rds" {
  source = "./rds"

  project_name      = var.project_name
  instance_class    = "db.t3.micro"
  username          = var.db_username
  password          = var.db_password
  database_name     = "mydatabase"
  db_subnet_ids     = module.vpc.private_db_subnet_ids
  security_group_ids = [aws_security_group.rds_sg.id]
  multi_az          = false
}

module "ec2" {
  source = "./ec2"

  project_name        = var.project_name
  instance_type       = var.instance_type
  min_size           = var.min_size
  max_size           = var.max_size
  private_subnet_ids = module.vpc.private_app_subnet_ids
  security_group_ids = [aws_security_group.ec2_sg.id]
  target_group_arn   = aws_lb_target_group.main.arn
  db_host           = module.rds.db_instance_address
  db_name           = module.rds.db_instance_name
}
