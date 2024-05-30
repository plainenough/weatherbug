provider "aws" {
  region = var.region
}


module "vpc" {
  source = "../../modules/vpc"
  region = var.region
  environment_name = var.environment_name
}


module "ecr" {
  source = "../../modules/ecr"
  environment_name = var.environment_name
}


module "eks" {
  source           = "../../modules/eks"
  environment_name = var.environment_name
  region           = var.region
  ecr_repository_arn = module.ecr.ecr_repository_arn
  depends_on = [
    module.ecr,
    module.vpc
  ]
}

