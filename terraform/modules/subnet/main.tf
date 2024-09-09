resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = var.public_vpc_id
  cidr_block        = var.public_subnet_cidrs[count.index]

  ### this will loop through a [list] based of index count ###
  availability_zone = element(var.azs, count.index % length(var.azs))
  tags = {
    Name      = "Public-${var.environment_name}-${var.region}-${var.azs[count.index]}"
    Project   = "weatherbug"
    ManagedBy = "terraform"
  }
}


resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = var.public_vpc_id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = element(var.azs, count.index % length(var.azs))
  tags = {
    Name      = "Private-${var.environment_name}-${var.region}-${var.azs[count.index]}"
    Project   = "weatherbug"
    ManagedBy = "terraform"
  }
}
