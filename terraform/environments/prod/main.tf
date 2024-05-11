provider "aws" {
  region = var.region
}

module "eks" {
  source           = "../../modules/eks"
  environment_name = var.environment_name
  region           = var.region
}

