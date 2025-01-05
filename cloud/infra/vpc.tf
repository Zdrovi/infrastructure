# Create VPC
resource "aws_vpc" "zdrovi_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "main"
  }
}

# Create Public Subnet (needed for EC2 Instance Connect)
resource "aws_subnet" "zdrovi_public_subnet" {
  vpc_id                  = aws_vpc.zdrovi_vpc.id
  cidr_block              = var.subnet_cidr
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = false  # We don't need public IPs

  tags = {
    Name = "public"
  }
}

# Create Internet Gateway (needed for EC2 Instance Connect)
resource "aws_internet_gateway" "zdrovi_internet_gateway" {
  vpc_id = aws_vpc.zdrovi_vpc.id

  tags = {
    Name = "main"
  }
}

# Create Route Table
resource "aws_route_table" "zdrovi_public_route_table" {
  vpc_id = aws_vpc.zdrovi_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.zdrovi_internet_gateway.id
  }

  tags = {
    Name = "public"
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "zdrovi_route_table_association" {
  subnet_id      = aws_subnet.zdrovi_public_subnet.id
  route_table_id = aws_route_table.zdrovi_public_route_table.id
}

# VPC Endpoint for EC2 Instance Connect
resource "aws_vpc_endpoint" "zdrovi_server_vpc_endpoint" {
  vpc_id             = aws_vpc.zdrovi_vpc.id
  service_name       = "com.amazonaws.${var.region}.ec2-instance-connect"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [aws_subnet.zdrovi_public_subnet.id]

  security_group_ids = [aws_security_group.zdrovi_server_vpc_endpoint_security_group.id]

  private_dns_enabled = true
}

# Security Group for VPC Endpoint
resource "aws_security_group" "zdrovi_server_vpc_endpoint_security_group" {
  name        = "zdrovi_server_vpc_endpoint_security_group"
  description = "Security group for VPC Endpoint"
  vpc_id      = aws_vpc.zdrovi_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name = "zdrovi_server_vpc_endpoint_security_group"
  }
}

# Security Group for EC2
resource "aws_security_group" "zdrovi_server_security_group" {
  name        = "zdrovi_server_security_group"
  description = "Security group for zdrovi_server EC2 Instance Connect"
  vpc_id      = aws_vpc.zdrovi_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "zdrovi_server_security_group"
  }
}