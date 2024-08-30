resource "aws_internet_gateway" "public_gateway" {
  vpc_id = var.public_vpc_id
  tags = {
    Name      = "Project VPC IG"
    Project   = "weatherbug"
    ManagedBy = "terraform"
  }
}
