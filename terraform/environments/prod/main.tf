provider "aws" {
  region = "us-east-2"
}


module "ecr" {
  source    = "../../modules/ecr"
  environment_name = "prod"
}


module "iam" {
  source           = "../../modules/iam"
}


module "vpc" {
  source    = "../../modules/vpc"
  environment_name = "prod"
  region = "us-east-2"

}


module "eks" {
  source           = "../../modules/eks"
  environment_name = "prod"
  region = "us-east-2"
}

