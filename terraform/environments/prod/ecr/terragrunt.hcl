terraform {
  source = "${get_repo_root()}modules/ecr"
}

inputs = {
  environment_name = "prod"
}
