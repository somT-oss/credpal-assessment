terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr           = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b"]
}

module "security" {
  source = "./modules/security"

  vpc_id = module.vpc.vpc_id
}

module "alb" {
  source = "./modules/alb"

  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  security_group_id = module.security.alb_sg_id
}

module "s3" {
  source = "./modules/s3"

  bucket_name = "credpal-deployment-artifacts-${random_id.suffix.hex}"
}

resource "random_id" "suffix" {
  byte_length = 4
}

module "iam" {
  source = "./modules/iam"

  github_repo           = "somT-oss/credpal-assessment" # Replace with actual repo
  deployment_bucket_arn = module.s3.bucket_arn
}

module "ec2" {
  source = "./modules/ec2"

  vpc_id                    = module.vpc.vpc_id
  public_subnet_ids         = module.vpc.public_subnet_ids
  security_group_id         = module.security.ec2_sg_id
  target_group_arn          = module.alb.target_group_arn
  iam_instance_profile_name = module.iam.ec2_instance_profile_name
}

module "codedeploy" {
  source = "./modules/codedeploy"

  service_role_arn       = module.iam.codedeploy_service_role_arn
  autoscaling_group_name = module.ec2.autoscaling_group_name
  target_group_name = module.alb.target_group_name
}

module "ecr" {
  source = "./modules/ecr"

  repository_name = "credpal-assessment"
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "s3_bucket_name" {
  value = module.s3.bucket_name
}
