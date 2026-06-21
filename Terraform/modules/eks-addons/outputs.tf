output "ebs_csi_addon_name" {
  description = "EBS CSI Driver addon name"
  value       = aws_eks_addon.ebs_csi_driver.addon_name
}

output "ebs_csi_driver_role_arn" {
  description = "IAM role ARN for EBS CSI Driver"
  value       = aws_iam_role.ebs_csi_driver.arn
}

output "metrics_server_release_name" {
  description = "Metrics Server Helm release name"
  value       = helm_release.metrics_server.name
}

output "nginx_ingress_release_name" {
  description = "NGINX Ingress Controller Helm release name"
  value       = helm_release.nginx_ingress.name
}
