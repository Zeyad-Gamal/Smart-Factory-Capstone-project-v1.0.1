locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

resource "aws_security_group" "ec2_management" {
  name        = "${local.name_prefix}-ec2-management-sg"
  description = "Security group for Jenkins, Prometheus, Grafana and SSH management EC2"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${local.name_prefix}-ec2-management-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ec2_ssh" {
  security_group_id = aws_security_group.ec2_management.id
  description       = "Allow SSH from admin IP"
  cidr_ipv4         = var.allowed_admin_cidr
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "ec2_jenkins" {
  security_group_id = aws_security_group.ec2_management.id
  description       = "Allow Jenkins from admin IP"
  cidr_ipv4         = var.allowed_admin_cidr
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}

resource "aws_vpc_security_group_ingress_rule" "ec2_prometheus" {
  security_group_id = aws_security_group.ec2_management.id
  description       = "Allow Prometheus from admin IP"
  cidr_ipv4         = var.allowed_admin_cidr
  from_port         = 9090
  ip_protocol       = "tcp"
  to_port           = 9090
}

resource "aws_vpc_security_group_ingress_rule" "ec2_grafana" {
  security_group_id = aws_security_group.ec2_management.id
  description       = "Allow Grafana from admin IP"
  cidr_ipv4         = var.allowed_admin_cidr
  from_port         = 3000
  ip_protocol       = "tcp"
  to_port           = 3000
}

resource "aws_vpc_security_group_egress_rule" "ec2_all_outbound" {
  security_group_id = aws_security_group.ec2_management.id
  description       = "Allow all outbound traffic from management EC2"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_security_group" "eks_cluster" {
  name        = "${local.name_prefix}-eks-cluster-sg"
  description = "Additional security group for EKS cluster communication"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${local.name_prefix}-eks-cluster-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "eks_from_vpc" {
  security_group_id = aws_security_group.eks_cluster.id
  description       = "Allow internal VPC traffic to EKS"
  cidr_ipv4         = var.vpc_cidr
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "eks_all_outbound" {
  security_group_id = aws_security_group.eks_cluster.id
  description       = "Allow all outbound traffic from EKS"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
