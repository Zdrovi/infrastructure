output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.zdrovi_server.public_ip
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.zdrovi_server.id
}

output "ami_id" {
  description = "ID of the AMI used"
  value       = data.aws_ami.ubuntu.id
}