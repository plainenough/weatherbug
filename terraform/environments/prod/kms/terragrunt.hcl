terraform {
  source = "${get_repo_root()}modules/kms"
}

inputs = {
  environment_name = "prod"
}
