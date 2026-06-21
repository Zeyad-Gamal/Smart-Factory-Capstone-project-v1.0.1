variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name such as dev, staging, prod"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "availability_zones" {
  description = "Availability zones for public and private subnets"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "allowed_admin_cidr" {
  description = "Admin public IP CIDR allowed to access EC2 management services"
  type        = string
}

variable "ec2_instance_type" {
  description = "Instance type for the EC2 management server"
  type        = string
}

variable "ec2_key_name" {
  description = "Name of the EC2 key pair"
  type        = string
}

variable "ec2_public_key_path" {
  description = "Path to the public SSH key"
  type        = string
}

variable "eks_cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
}

variable "eks_node_instance_types" {
  description = "Instance types for EKS managed worker nodes"
  type        = list(string)
}

variable "eks_desired_size" {
  description = "Desired number of EKS worker nodes"
  type        = number
}

variable "eks_min_size" {
  description = "Minimum number of EKS worker nodes"
  type        = number
}

variable "eks_max_size" {
  description = "Maximum number of EKS worker nodes"
  type        = number
}
