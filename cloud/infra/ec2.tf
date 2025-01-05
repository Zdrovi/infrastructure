# Get latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"] # Canonical

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "root-device-type"
    values = ["ebs"]
  }
}

# IAM role for EC2
resource "aws_iam_role" "zdrovi_server_ec2_role" {
  name = "ec2_instance_connect_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy for EC2 Instance Connect
resource "aws_iam_role_policy" "zdrovi_server_instance_connect_policy" {
  name = "zdrovi_server_instance_connect_policy"
  role = aws_iam_role.zdrovi_server_ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2-instance-connect:SendSSHPublicKey"
        ]
        Resource = "*"
      }
    ]
  })
}

# Create key pair
resource "aws_key_pair" "zdrovi_server_key" {
  key_name   = "zdrovi_server_key"
  public_key = tls_private_key.ssh.public_key_openssh
}

# Generate SSH key
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Store private key in SSM Parameter Store
resource "aws_ssm_parameter" "zdrovi_server_ssh_private_key" {
  name  = "/ec2/zdrovi_server_ssh_private_key"
  type  = "SecureString"
  value = tls_private_key.ssh.private_key_pem
}

# Create instance profile
resource "aws_iam_instance_profile" "zdrovi_server_ec2_profile" {
  name = "zdrovi_server_ec2_profile"
  role = aws_iam_role.zdrovi_server_ec2_role.name
}

# Create EC2 Instance
resource "aws_instance" "zdrovi_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.zdrovi_public_subnet.id
  vpc_security_group_ids = [aws_security_group.zdrovi_server_security_group.id]
  key_name                    = aws_key_pair.zdrovi_server_key.key_name
  associate_public_ip_address = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  tags = {
    Name = var.instance_name
  }

  root_block_device {
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = true
  }
}