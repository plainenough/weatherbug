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


resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.public_vpc.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = "${var.region}${var.azs[count.index]}"
  tags = {
    Name      = "Public-${var.environment_name}-${var.region}-${var.azs[count.index]}"
    Project   = "weatherbug"
    ManagedBy = "terraform"
  }
}


resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.public_vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = "${var.region}${var.azs[count.index]}"
  tags = {
    Name      = "Private-${var.environment_name}-${var.region}-${var.azs[count.index]}"
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

# This assumes that subnets order is maintained throughout creation.
resource "aws_nat_gateway" "nat_1" {
  allocation_id = aws_eip.nat_a.id
  subnet_id     = aws_subnet.public_subnets[0].id
  tags = {
    Name      = "NAT Gateway 1"
    Project   = "weatherbug"
    ManagedBy = "terraform"
  }
  depends_on = [aws_internet_gateway.public_gateway, aws_eip.nat_a]
}


resource "aws_nat_gateway" "nat_2" {
  allocation_id = aws_eip.nat_b.id
  subnet_id     = aws_subnet.public_subnets[1].id
  tags = {
    Name      = "NAT Gateway 2"
    Project   = "weatherbug"
    ManagedBy = "terraform"
  }
  depends_on = [aws_internet_gateway.public_gateway, aws_eip.nat_b]
}


resource "aws_nat_gateway" "nat_3" {
  allocation_id = aws_eip.nat_c.id
  subnet_id     = aws_subnet.public_subnets[2].id
  tags = {
    Name      = "NAT Gateway 3"
    Project   = "weatherbug"
    ManagedBy = "terraform"
  }
  depends_on = [aws_internet_gateway.public_gateway, aws_eip.nat_c]
}


resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.public_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public_gateway.id
  }
  tags = {
    Name      = "Public Route Table"
    Project   = "weatherbug"
    ManagedBy = "terraform"
  }
  depends_on = [aws_internet_gateway.public_gateway]
}

resource "aws_route_table_association" "public" {
  count          = 3
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private" {
  count  = 3
  vpc_id = aws_vpc.public_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = element([
      aws_nat_gateway.nat_1.id,
      aws_nat_gateway.nat_2.id,
      aws_nat_gateway.nat_3.id
    ], count.index)
  }
  tags = {
    Name      = "Private-Subnet-RouteTable-${count.index}"
    Project   = "weatherbug"
    ManagedBy = "terraform"
  }
  depends_on = [aws_nat_gateway.nat_1,
    aws_nat_gateway.nat_2,
  aws_nat_gateway.nat_3]
}


resource "aws_route_table_association" "private" {
  count          = 3
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}


module "vpc" {
  source = "./vpc"
  environment_name = var.environment_name
  public_vpc_id = aws_vpc.public_vpc.id
  depends_on = [aws_vpc.public_vpc]
}
