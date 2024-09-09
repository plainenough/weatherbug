terraform {
  source = "${get_repo_root()}modules/securityGroups"
}


dependency "vpc" {
  config_path = "../vpc"
}

dependency "subnet" {
  config_path = "../subnet"
}


inputs = {
  environment_name = "prod"
  private_subnet_cidrs = ["10.0.0.48/28", "10.0.0.64/28", "10.0.0.80/28"]
  private_subnet_ids = dependency.subnet.outputs.private_subnet_ids
  public_vpc_id = dependency.vpc.outputs.vpc_id
}
