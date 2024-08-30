terraform {
    source = "../../../modules/eip"
}

inputs = {
    azs = ["us-east-2a", "us-east-2b", "us-east-2c"]
}
