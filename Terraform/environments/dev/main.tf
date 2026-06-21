module "vpc" {
  source = "../../modules/vpc"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "security_groups" {
  source = "../../modules/security-groups"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  vpc_cidr           = var.vpc_cidr
  allowed_admin_cidr = var.allowed_admin_cidr
}

module "ec2_management" {
  source = "../../modules/ec2-management"

  project_name      = var.project_name
  environment       = var.environment
  instance_type     = var.ec2_instance_type
  key_name          = var.ec2_key_name
  public_key_path   = var.ec2_public_key_path
  public_subnet_id  = module.vpc.public_subnet_ids[0]
  security_group_id = module.security_groups.ec2_management_sg_id
}

module "eks" {
  source = "../../modules/eks"

  project_name              = var.project_name
  environment               = var.environment
  cluster_version           = var.eks_cluster_version
  private_subnet_ids        = module.vpc.private_subnet_ids
  cluster_security_group_id = module.security_groups.eks_cluster_sg_id
  allowed_admin_cidr        = var.allowed_admin_cidr
  node_instance_types       = var.eks_node_instance_types
  desired_size              = var.eks_desired_size
  min_size                  = var.eks_min_size
  max_size                  = var.eks_max_size
}

data "tls_certificate" "eks_oidc" {
  url = module.eks.cluster_oidc_issuer_url
}

module "eks_addons" {
  source = "../../modules/eks-addons"

  project_name            = var.project_name
  environment             = var.environment
  cluster_name            = module.eks.cluster_name
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  oidc_thumbprint         = data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint
}
