terraform {
  source = "../../../modules/kms"
}

inputs = {
  environment_name = "prod"
}
