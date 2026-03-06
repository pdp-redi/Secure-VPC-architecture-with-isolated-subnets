# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project}-vpc"
  }
}

# Public Subnets
resource "aws_subnet" "public_subnets" {
  for_each = local.public_subnets

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project}-${each.key}"
    Tier = "public"
  }
}

# Private Subnets for Applications
resource "aws_subnet" "private_app_subnets" {
  for_each = local.private_app_subnets

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${var.project}-${each.key}"
    Tier = "application"
  }
}

# Private Subnets for Databases
resource "aws_subnet" "private_db_subnets" {
  for_each = local.private_db_subnets

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${var.project}-${each.key}"
    Tier = "database"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project}-igw"
  }
}

# EIP for NAT Gateway
resource "aws_eip" "nat_eip" {
  for_each = aws_subnet.public_subnets # Allocate one EIP per public subnet for NAT HA
  domain   = "vpc"

  tags = {
    Name = "${var.project}-nat-eip-${each.key}"
    #Name = "${var.project}-nat-eip"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  for_each      = aws_subnet.public_subnets
  allocation_id = aws_eip.nat_eip[each.key].id
  #allocation_id = aws_eip.nat.id
  subnet_id = each.value.id

  #subnet_id = values(aws_subnet.public)[0].id

  tags = {
    Name = "${var.project}-nat-${each.key}"
    #Name = "${var.project}-nat"
  }
  depends_on = [aws_internet_gateway.igw]
}

# Route Table for Public Subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {

    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id

  }

  tags = {
    Name = "${var.project}-public-route-table"
  }
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public_route_table_association" {
  for_each = aws_subnet.public_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table.id

}

# Route Table for Private Subnets
resource "aws_route_table" "private_route_table" {
  for_each = aws_nat_gateway.nat
  vpc_id   = aws_vpc.vpc.id

  route {

    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = each.value.id
    #nat_gateway_id = aws_nat_gateway.nat.id

  }

  tags = {
    Name = "${var.project}-private-route-table-${each.key}"
    #Name = "${var.project}-private-rt"
  }
}

# Associate Private Subnets with Private Route Table
resource "aws_route_table_association" "app_private_route_table_association" {
  for_each = aws_subnet.private_app_subnets

  subnet_id      = each.value.id
  #route_table_id = aws_route_table.private_route_table[each.key].id
  route_table_id = aws_route_table.private_route_table[
    "public-${split("-", each.key)[1]}"
    ].id
}

# Route Table for DB Private Subnets
resource "aws_route_table" "db_private_route_table" {

  for_each = aws_subnet.private_db_subnets

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project}-db-private-rt-${each.key}"
  }
}
# Associate DB Private Subnets with Private Route Table
resource "aws_route_table_association" "db_private_route_table_association" {
  for_each = aws_subnet.private_db_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.db_private_route_table[each.key].id
 
}
