terraform {
  required_version = ">= 1.13.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "eks-2048-terraform-state"
    key            = "eks/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "eks-2048-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source             = "./modules/vpc"
  project_name       = var.project_name
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
}

module "iam" {
  source            = "./modules/iam"
  project_name      = var.project_name
  oidc_provider_arn = module.eks.oidc_provider_arn
 oidc_provider_url = replace(module.eks.oidc_provider_url, "https://", "")
}

module "eks" {
  source           = "./modules/eks"
  project_name     = var.project_name
  vpc_id           = module.vpc.vpc_id
  private_subnets  = module.vpc.private_subnet_ids
  node_role_arn    = module.iam.node_role_arn
  cluster_role_arn = module.iam.cluster_role_arn
}
