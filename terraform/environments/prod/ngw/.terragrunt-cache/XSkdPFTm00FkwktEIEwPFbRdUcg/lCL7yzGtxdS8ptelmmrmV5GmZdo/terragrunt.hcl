terraform {
  source = "../../../modules/ngw"
}

dependency "subnet" {
  config_path = "../subnet"
}

dependency "eip" {
  config_path = "../eip"
}

inputs = {
  public_subnet_ids = dependency.subnet.outputs.public_subnet_ids
  eips = dependency.eip.outputs.eips
}
