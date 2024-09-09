terraform {
    source = "${get_repo_root()}modules/subnet"
}

dependency "vpc" {
    config_path = "../vpc"
}

inputs = {
    region = "us-east-2"
    environment_name = "prod"
    public_subnet_cidrs = ["10.0.0.0/28", "10.0.0.16/28", "10.0.0.32/28"]
    private_subnet_cidrs = ["10.0.0.48/28", "10.0.0.64/28", "10.0.0.80/28"]
    azs = ["us-east-2a", "us-east-2b", "us-east-2c"]
    public_vpc_id = dependency.vpc.outputs.vpc_id
    eks_cluster_name = "weatherbug"
}
