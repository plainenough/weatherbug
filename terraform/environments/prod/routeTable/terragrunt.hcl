terraform {
  source = "../../../modules/routeTable"
}


dependency "vpc" {
  config_path = "../vpc"
}


dependency "igw" {
  config_path = "../igw"
}

dependency "subnet" {
  config_path = "../subnet"
}

dependency "ngw" {
  config_path = "../ngw"
}

inputs = {
  vpc_cidr = "10.0.0.0/16"
  nat_gateway_ids = dependency.ngw.outputs.nat_gateways
  private_subnet_ids = dependency.subnet.outputs.private_subnet_ids
  public_subnet_ids = dependency.subnet.outputs.public_subnet_ids
  public_vpc_id = dependency.vpc.outputs.vpc_id
  public_gateway_id = dependency.igw.outputs.public_gateway_id
}
