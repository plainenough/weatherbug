provider "aws" {
  region = var.region
}


module "ecr" {
  source           = "../../modules/ecr"
  environment_name = var.environment_name
}


module "iam" {
  source = "../../modules/iam"
}


module "vpc" {
  source           = "../../modules/vpc"
  environment_name = var.environment_name
  region           = var.region

}


module "eks" {
  source           = "../../modules/eks"
  environment_name = var.environmnent_name
  region           = var.region
}

