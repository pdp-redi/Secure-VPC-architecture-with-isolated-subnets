# This file defines the output values for the VPC module, including the VPC ID and subnet IDs for public, app, and database subnets.
output "vpc_id" {
  value = aws_vpc.vpc.id
}

# Output the IDs of the public subnets
output "public_subnets" {
  value = [for s in aws_subnet.public_subnets : s.id]
}

# Output the IDs of the app private subnets
output "app_subnets" {
  value = [for s in aws_subnet.private_app_subnets : s.id]
}

# Output the IDs of the database private subnets
output "db_subnets" {
  value = [for s in aws_subnet.private_db_subnets : s.id]
}