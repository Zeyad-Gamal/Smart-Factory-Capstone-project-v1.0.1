output "vpc_id" {
  description = "Created VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = module.vpc.nat_gateway_id
}

output "ec2_management_sg_id" {
  description = "Security group ID for EC2 management server"
  value       = module.security_groups.ec2_management_sg_id
}

output "eks_cluster_sg_id" {
  description = "Additional security group ID for EKS cluster"
  value       = module.security_groups.eks_cluster_sg_id
}

output "ec2_management_instance_id" {
  description = "EC2 management instance ID"
  value       = module.ec2_management.instance_id
}

output "ec2_management_public_ip" {
  description = "EC2 management public IP"
  value       = module.ec2_management.public_ip
}

output "ec2_management_public_dns" {
  description = "EC2 management public DNS"
  value       = module.ec2_management.public_dns
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_node_group_name" {
  description = "EKS managed node group name"
  value       = module.eks.node_group_name
}

output "ebs_csi_addon_name" {
  description = "EBS CSI Driver addon name"
  value       = module.eks_addons.ebs_csi_addon_name
}

output "ebs_csi_driver_role_arn" {
  description = "IAM role ARN for EBS CSI Driver"
  value       = module.eks_addons.ebs_csi_driver_role_arn
}

output "nginx_ingress_release_name" {
  description = "NGINX Ingress Controller Helm release name"
  value       = module.eks_addons.nginx_ingress_release_name
}
