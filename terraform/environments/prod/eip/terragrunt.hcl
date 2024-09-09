terraform {
    source = "${get_repo_root()}modules/eip"
}

inputs = {
    azs = ["us-east-2a", "us-east-2b", "us-east-2c"]
}
