# modules/vpc/outputs.tf
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_app_subnet_ids" {
  description = "List of private app subnet IDs"
  value       = aws_subnet.private_app[*].id
}

output "private_db_subnet_ids" {
  description = "List of private database subnet IDs"
  value       = aws_subnet.private_db[*].id
}

output "nat_gateway_ips" {
  description = "List of NAT Gateway public IPs"
  value       = aws_eip.nat[*].public_ip
}

# Add these missing outputs that the modules expect
output "private_subnet_ids" {
  description = "All private subnet IDs (app and db combined)"
  value       = concat(aws_subnet.private_app[*].id, aws_subnet.private_db[*].id)
}

output "availability_zones" {
  description = "List of availability zones used"
  value       = var.availability_zones
}
