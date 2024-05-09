resource "aws_ecr_repository" "ecr_repo" {
  name                 = "weatherbug-repo"
  image_tag_mutability = "MUTABLE" 
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Environment = "${var.environment_name}"
    Project     = "weatherbug"
    ManagedBy = "terraform"
  }
}