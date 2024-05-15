resource "aws_vpc" "public_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name      = "VPC-${var.region}-${var.environment_name}"
    Project   = "weatherbug"
    ManagedBy = "terraform"
  }
}



# This assumes that subnets order is maintained throughout creation.
resource "aws_eip" "nat_a" {
  domain = "vpc"
  tags = {
    Name      = "EIP for NAT Gateway AZ-a"
    Project   = "weatherbug"
    ManagedBy = "terraform"
  }
}


resource "aws_eip" "nat_b" {
  domain = "vpc"
  tags = {
    Name      = "EIP for NAT Gateway AZ-b"
    Project   = "weatherbug"
    ManagedBy = "terraform"
  }
}


resource "aws_eip" "nat_c" {
  domain = "vpc"
  tags = {
    Name      = "EIP for NAT Gateway AZ-c"
    Project   = "weatherbug"
    ManagedBy = "terraform"
  }
}


resource "aws_internet_gateway" "public_gateway" {
  vpc_id = aws_vpc.public_vpc.id
  tags = {
    Name      = "Project VPC IG"
    Project   = "weatherbug"
    ManagedBy = "terraform"
  }
}


locals {
  nat_gateways = {
    nat_1 = {
      allocation_id = aws_eip.nat_a.id
      subnet_id     = module.subnets.public_subnet_ids[0]
      name          = "NAT Gateway 1"
    }
    nat_2 = {
      allocation_id = aws_eip.nat_b.id
      subnet_id     = module.subnets.public_subnet_ids[1]
      name          = "NAT Gateway 2"
    }
    nat_3 = {
      allocation_id = aws_eip.nat_c.id
      subnet_id     = module.subnets.public_subnet_ids[2]
      name          = "NAT Gateway 3"
    }
  }
}


resource "aws_nat_gateway" "nat_gateways" {
  for_each       = local.nat_gateways
  allocation_id  = each.value.allocation_id
  subnet_id      = each.value.subnet_id

  tags = {
    Name      = each.value.name
    Project   = "weatherbug"
    ManagedBy = "terraform"
  }

  depends_on = [aws_internet_gateway.public_gateway, aws_eip.nat_a, aws_eip.nat_b, aws_eip.nat_c, module.subnets]
}


module "security-groups" {
  source = "./security-groups"
  environment_name = var.environment_name
  public_vpc_id = aws_vpc.public_vpc.id
  depends_on = [aws_vpc.public_vpc]
}


module "subnets" {
  source = "./subnets"
  environment_name = var.environment_name
  public_vpc_id = aws_vpc.public_vpc.id
  region            = var.region
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  depends_on = [aws_vpc.public_vpc]
}

module "route-tables" {
  source = "./route-tables"
  environment_name = var.environment_name
  public_vpc_id = aws_vpc.public_vpc.id
  nat_gateway_ids = [aws_nat_gateway.nat_gateways[0].id, aws_nat_gateway.nat_gateways[1].id, aws_nat_gateway.nat_gateways[2]]
  region            = var.region
  vpc_cidr_block = var.vpc_cidr_block
  public_gateway_id = aws_internet_gateway.public_gateway
  public_subnet_ids = module.subnets.public_subnet_ids
  private_subnet_ids = module.subnets.private_subnet_ids
  depends_on = [aws_nat_gateway.nat_gatways]
}