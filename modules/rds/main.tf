# modules/rds/main.tf

data "aws_rds_engine_version" "mysql" {
  engine  = "mysql"
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

resource "aws_db_instance" "main" {
  identifier             = "${var.project_name}-db"
  engine                 = data.aws_rds_engine_version.mysql.engine
  engine_version         = data.aws_rds_engine_version.mysql.version
  instance_class         = var.instance_class
  allocated_storage      = 20
  max_allocated_storage  = 100
  storage_type           = "gp2"
  storage_encrypted      = true

  username = var.username
  password = var.password
  db_name = var.database_name

  multi_az               = var.multi_az
  publicly_accessible    = false
  vpc_security_group_ids = var.security_group_ids
  db_subnet_group_name   = aws_db_subnet_group.main.name

  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  skip_final_snapshot    = true
  deletion_protection    = false

  apply_immediately = true

  tags = {
    Name = "${var.project_name}-rds"
  }
}

output "db_instance_address" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.main.address
}

output "db_instance_name" {
  description = "RDS database name"
  value       = aws_db_instance.main.db_name
}  
