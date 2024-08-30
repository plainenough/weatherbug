resource "aws_vpc" "public_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name      = "VPC-${var.region}-${var.environment_name}"
    Project   = "weatherbug"
    ManagedBy = "terraform"
  }
}
