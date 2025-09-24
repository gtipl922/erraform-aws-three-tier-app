# modules/rds/variables.tf
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "username" {
  description = "Database administrator username"
  type        = string
  sensitive   = true
}

variable "password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}

variable "database_name" {
  description = "Name of the database to create"
  type        = string
  default     = "mydatabase"
}

variable "db_subnet_ids" {
  description = "List of private subnet IDs for DB subnets"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = false
}

