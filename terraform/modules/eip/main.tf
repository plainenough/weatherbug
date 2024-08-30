# This assumes that subnets order is maintained throughout creation.
resource "aws_eip" "nat" {
  count = length(var.azs)
  domain = "vpc"
  tags = {
    Name      = "EIP for NAT Gateway ${element(var.azs, count.index)}"
    Project   = "weatherbug"
    ManagedBy = "terraform"
  }
}
