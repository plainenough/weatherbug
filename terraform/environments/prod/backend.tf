terraform {
  backend "s3" {
    bucket         = "weatherbug-terraform"
    key            = "state/prod/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
