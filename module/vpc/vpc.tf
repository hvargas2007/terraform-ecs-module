# VPC application Definition 
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = merge(var.project-tags, { Name = "${var.name_prefix}-vpc" }, )
}

# VPC Flow Logs to CloudWatch
resource "aws_flow_log" "VpcFlowLog" {
  iam_role_arn    = aws_iam_role.vpc_fl_policy_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_log_group.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.vpc.id
}

################################################################################
# INTERNET GATEWAY (CONDICIONAL)
################################################################################
resource "aws_internet_gateway" "igw" {
  count  = var.create_internet_gateway ? 1 : 0
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.project-tags, { Name = "${var.name_prefix}-IGW" }, )
}

################################################################################
# PUBLIC SUBNETS (CONDICIONAL)
################################################################################
resource "aws_subnet" "public" {
  for_each                = var.create_public_subnets ? { for i, v in var.PublicSubnet : i => v } : {}
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge(var.project-tags, { Name = "${each.value.name}" }, )
}

################################################################################
# PRIVATE SUBNETS
################################################################################
# Private Subnet application Definition
resource "aws_subnet" "private" {
  for_each          = { for i, v in var.PrivateSubnet : i => v }
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(var.project-tags, { Name = "${each.value.name}" }, )
}

# Private Subnet database Definition
resource "aws_subnet" "private_db" {
  for_each          = { for i, v in var.PrivateSubnetDb : i => v }
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(var.project-tags, { Name = "${each.value.name}" }, )
}

################################################################################
# NAT GATEWAY (CONDICIONAL)
################################################################################
# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count  = var.create_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.PublicSubnet)) : 0
  vpc   = true

  tags = merge(var.project-tags, { Name = "${var.name_prefix}-EIP-NAT-${count.index + 1}" }, )
}

# NAT Gateways
resource "aws_nat_gateway" "nat" {
  count         = var.create_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.PublicSubnet)) : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = var.single_nat_gateway ? aws_subnet.public[0].id : aws_subnet.public[count.index].id

  tags = merge(var.project-tags, { Name = "${var.name_prefix}-NAT-${count.index + 1}" }, )

  depends_on = [aws_internet_gateway.igw]
}

################################################################################
# TRANSIT GATEWAY ATTACHMENT (CONDICIONAL)
################################################################################
resource "aws_ec2_transit_gateway_vpc_attachment" "transit_attachment_application" {
  count              = var.use_transit_gateway ? 1 : 0
  transit_gateway_id = var.transit_id
  vpc_id             = aws_vpc.vpc.id
  subnet_ids         = [for s in aws_subnet.private : s.id]

  tags = merge(var.project-tags, { Name = "${var.name_prefix}-TGW-Attach" }, )
}

################################################################################
# ROUTE TABLES
################################################################################
# Public Route Table (condicional)
resource "aws_route_table" "public" {
  count  = var.create_public_subnets ? 1 : 0
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.project-tags, { Name = "${var.name_prefix}-PublicRouteTable" }, )
}

# Public Route to Internet Gateway
resource "aws_route" "public_internet" {
  count                  = var.create_public_subnets && var.create_internet_gateway ? 1 : 0
  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw[0].id
}

# Private Route Tables (one per AZ if using multiple NAT Gateways)
resource "aws_route_table" "private" {
  count  = var.single_nat_gateway || !var.create_nat_gateway ? 1 : length(var.PrivateSubnet)
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.project-tags, { Name = "${var.name_prefix}-PrivateRouteTable-${count.index + 1}" }, )
}

# Private Routes - Dynamic based on configuration
resource "aws_route" "private_nat_gateway" {
  count = var.create_nat_gateway && !var.use_transit_gateway ? (var.single_nat_gateway ? 1 : length(var.PrivateSubnet)) : 0

  route_table_id         = var.single_nat_gateway ? aws_route_table.private[0].id : aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.single_nat_gateway ? aws_nat_gateway.nat[0].id : aws_nat_gateway.nat[count.index].id
}

resource "aws_route" "private_transit_gateway" {
  count = var.use_transit_gateway ? (var.single_nat_gateway || !var.create_nat_gateway ? 1 : length(var.PrivateSubnet)) : 0

  route_table_id         = var.single_nat_gateway || !var.create_nat_gateway ? aws_route_table.private[0].id : aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = var.transit_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.transit_attachment_application]
}

# Private Route Table for Database (isolated)
resource "aws_route_table" "private_db" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.project-tags, { Name = "${var.name_prefix}-PrivateRouteTableDb" }, )
}

################################################################################
# ROUTE TABLE ASSOCIATIONS
################################################################################
# Public Subnets Association
resource "aws_route_table_association" "public" {
  for_each       = var.create_public_subnets ? { for i, v in var.PublicSubnet : i => v } : {}
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public[0].id
}

# Private Subnets Association
resource "aws_route_table_association" "private" {
  count          = length(var.PrivateSubnet)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = var.single_nat_gateway || !var.create_nat_gateway ? aws_route_table.private[0].id : aws_route_table.private[count.index].id
}

# Database Subnets Association
resource "aws_route_table_association" "database" {
  count          = length(var.PrivateSubnetDb)
  subnet_id      = aws_subnet.private_db[count.index].id
  route_table_id = aws_route_table.private_db.id
}