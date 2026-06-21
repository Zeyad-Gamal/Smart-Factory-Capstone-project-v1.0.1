output "instance_id" {
  description = "EC2 management instance ID"
  value       = aws_instance.management.id
}

output "public_ip" {
  description = "EC2 management public IP"
  value       = aws_instance.management.public_ip
}

output "public_dns" {
  description = "EC2 management public DNS"
  value       = aws_instance.management.public_dns
}

output "private_ip" {
  description = "EC2 management private IP"
  value       = aws_instance.management.private_ip
}
