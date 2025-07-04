output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "VPC ID"
}

output "vpc_cidr_block" {
  value       = aws_vpc.vpc.cidr_block
  description = "VPC CIDR block"
}

# Private Subnets
output "private_subnet_ids" {
  value       = values(aws_subnet.private)[*].id
  description = "List of private subnet IDs"
}

output "private_subnet_cidrs" {
  value       = values(aws_subnet.private)[*].cidr_block
  description = "List of private subnet CIDR blocks"
}

# Database Subnets
output "private_subnet_db_ids" {
  value       = values(aws_subnet.private_db)[*].id
  description = "List of database subnet IDs"
}

output "private_subnet_db_cidrs" {
  value       = values(aws_subnet.private_db)[*].cidr_block
  description = "List of database subnet CIDR blocks"
}

# Public Subnets (condicional)
output "public_subnet_ids" {
  value       = var.create_public_subnets ? values(aws_subnet.public)[*].id : []
  description = "List of public subnet IDs (empty if not created)"
}

output "public_subnet_cidrs" {
  value       = var.create_public_subnets ? values(aws_subnet.public)[*].cidr_block : []
  description = "List of public subnet CIDR blocks (empty if not created)"
}

# Internet Gateway (condicional)
output "internet_gateway_id" {
  value       = var.create_internet_gateway ? aws_internet_gateway.igw[0].id : null
  description = "Internet Gateway ID (null if not created)"
}

# NAT Gateway (condicional)
output "nat_gateway_ids" {
  value       = var.create_nat_gateway ? aws_nat_gateway.nat[*].id : []
  description = "List of NAT Gateway IDs (empty if not created)"
}

output "nat_gateway_public_ips" {
  value       = var.create_nat_gateway ? aws_eip.nat[*].public_ip : []
  description = "List of Elastic IP addresses for NAT Gateways"
}

# Transit Gateway Attachment (condicional)
output "transit_gateway_attachment_id" {
  value       = var.use_transit_gateway ? aws_ec2_transit_gateway_vpc_attachment.transit_attachment_application[0].id : null
  description = "Transit Gateway Attachment ID (null if not created)"
}

# Route Tables
output "private_route_table_ids" {
  value       = aws_route_table.private[*].id
  description = "List of private route table IDs"
}

output "public_route_table_id" {
  value       = var.create_public_subnets ? aws_route_table.public[0].id : null
  description = "Public route table ID (null if not created)"
}

output "database_route_table_id" {
  value       = aws_route_table.private_db.id
  description = "Database route table ID"
}