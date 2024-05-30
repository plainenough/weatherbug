provider "aws" {
  region = var.region
}


module "vpc" {
  source = "../../modules/vpc"
  region = var.region
  environment_name = var.environment_name
  eks_cluster_name = "${var.region}-eks-${var.environment_name}"
}


module "ecr" {
  source = "../../modules/ecr"
  environment_name = var.environment_name
}


module "eks" {
  source           = "../../modules/eks"
  environment_name = var.environment_name
  region           = var.region
  private_subnet_ids = module.vpc.private_subnet_ids
  ecr_repository_arn = module.ecr.ecr_repository_arn
  eks_node_sg_id     = module.vpc.eks_node_sg_id
  eks_cluster_name = "${var.region}-eks-${var.environment_name}"
  private_sg_id      = module.vpc.private_sg_id 
  eks_control_plane_sg_id = module.vpc.eks_control_plane_sg_id
  depends_on = [
    module.ecr,
    module.vpc
  ]
}

