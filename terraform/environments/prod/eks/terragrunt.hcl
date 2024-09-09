terraform {
  source = "../../../modules/eks"
}


dependency "vpc" {
  config_path = "../vpc"
}

dependency "subnet" {
  config_path = "../subnet"
}

dependency "securityGroups" {
  config_path = "../securityGroups"
}

dependency "ecr" {
  config_path = "../ecr"
}

inputs = {
  environment_name = "prod"
  region = "us-east-2"
  ecr_repository_arn = dependency.ecr.outputs.ecr_repository_arn
  eks_node_sg_id = dependency.securityGroups.outputs.eks_node_sg_id
  private_sg_id = dependency.securityGroups.outputs.private_sg_id
  eks_control_plane_sg_id = dependency.securityGroups.outputs.eks_control_plane_sg_id
  eks_cluster_name = "weatherbug" 
  private_subnet_cidrs = ["10.0.0.48/28", "10.0.0.64/28", "10.0.0.80/28"]
  private_subnet_ids = dependency.subnet.outputs.private_subnet_ids
  public_vpc_id = dependency.vpc.outputs.vpc_id
}
