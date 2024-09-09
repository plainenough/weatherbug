terraform {
    source = "${get_repo_root()}modules/vpc"
}


inputs = {
  region = "us-east-2"
  environment_name = "prod"
  vpc_cidr = "10.0.0.0/16"
}
