variable "region" {
  description = "AWS Region"
  type        = string
  default     = "eu-central-1"  # Frankfurt
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"  # Free tier eligible
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "zdrovi-server"
}