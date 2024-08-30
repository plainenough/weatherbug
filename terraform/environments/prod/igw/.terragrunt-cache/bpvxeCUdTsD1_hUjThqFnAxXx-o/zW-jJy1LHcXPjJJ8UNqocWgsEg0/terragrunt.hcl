terraform {
  source = "../../../modules/igw"
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  public_vpc_id = dependency.vpc.outputs.vpc_id
}
