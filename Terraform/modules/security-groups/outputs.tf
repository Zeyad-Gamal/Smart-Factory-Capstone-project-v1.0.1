output "ec2_management_sg_id" {
  description = "Security group ID for EC2 management server"
  value       = aws_security_group.ec2_management.id
}

output "eks_cluster_sg_id" {
  description = "Additional security group ID for EKS cluster"
  value       = aws_security_group.eks_cluster.id
}
