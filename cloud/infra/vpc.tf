# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "main"
  }
}

# Create Public Subnet (needed for EC2 Instance Connect)
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = false  # We don't need public IPs

  tags = {
    Name = "public"
  }
}

# Create Internet Gateway (needed for EC2 Instance Connect)
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

# Create Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public"
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# VPC Endpoint for EC2 Instance Connect
resource "aws_vpc_endpoint" "ec2_instance_connect" {
  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.${var.region}.ec2-instance-connect"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [aws_subnet.public.id]

  security_group_ids = [aws_security_group.vpc_endpoint.id]

  private_dns_enabled = true
}

# Security Group for VPC Endpoint
resource "aws_security_group" "vpc_endpoint" {
  name        = "vpc-endpoint-sg"
  description = "Security group for VPC Endpoint"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name = "vpc-endpoint-sg"
  }
}

# Security Group for EC2
resource "aws_security_group" "ec2" {
  name        = "ec2-instance-connect"
  description = "Security group for EC2 Instance Connect"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-instance-connect"
  }
}