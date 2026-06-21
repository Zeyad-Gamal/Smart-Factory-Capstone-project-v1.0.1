variable "project_name" {
  description = "Project name used for naming resources"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "public_key_path" {
  description = "Local path to the SSH public key"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID where EC2 management server will be launched"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID attached to EC2 management server"
  type        = string
}
