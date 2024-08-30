resource "aws_nat_gateway" "nat_gateways" {
  count = length(var.eips)
  allocation_id  = element(var.eips, count.index)
  subnet_id      = element(var.public_subnet_ids, count.index)

  tags = {
    Name      = "NAT Gateway ${count.index + 1}}"
    Project   = "weatherbug"
    ManagedBy = "terraform"
  }
}
