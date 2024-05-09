resource "aws_vpc" "public_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "VPC-${var.region}-${var.environment_name}"
  }
}


resource "aws_subnet" "public_subnets" {
  count      = length(var.public_subnets_cidr)
  vpc_id     = aws_vpc.public_vpc.id
  cidr_block = var.public_subnets_cidr[count.index]
  availability_zone = "${var.region}${var.azs[count.index]}"
  tags = {
    Name = "Public-${var.environment_name}-${var.region}-${var.azs[count.index]}"
  }
}


resource "aws_subnet" "private_subnets" {
  count      = length(var.private_subnets_cidr)
  vpc_id     = aws_vpc.public_vpc.id
  cidr_block = var.private_subnets_cidr[count.index]
  availability_zone = "${var.region}${var.azs[count.index]}"
  tags = {
    Name = "Private-${var.environment_name}-${var.region}-${var.azs[count.index]}"
  }
}


# This assumes that subnets order is maintained throughout creation.
resource "aws_eip" "nat_a" {
  vpc = true
  tags = {
    Name = "EIP for NAT Gateway AZ-a"
  }
}


resource "aws_eip" "nat_b" {
  vpc = true
  tags = {
    Name = "EIP for NAT Gateway AZ-b"
  }
}


resource "aws_eip" "nat_c" {
  vpc = true
  tags = {
    Name = "EIP for NAT Gateway AZ-c"
  }
}


resource "aws_internet_gateway" "public_gateway" {
 vpc_id = aws_vpc.public_vpc.id
 tags = {
   Name = "Project VPC IG"
 }
}


# This assumes that subnets order is maintained throughout creation.
resource "aws_nat_gateway" "nat_1" {
  allocation_id = aws_eip.nat_a.id
  subnet_id     = aws_subnet.private_subnets[0].id  
  tags = {
    Name = "NAT Gateway"
  }
  depends_on = [aws_internet_gateway.public_gateway, aws_eip.nat_a]
}


resource "aws_nat_gateway" "nat_2" {
  allocation_id = aws_eip.nat_b.id
  subnet_id     = aws_subnet.private_subnets[1].id  
  tags = {
    Name = "NAT Gateway"
  }
  depends_on = [aws_internet_gateway.public_gateway, aws_eip.nat_b]
}


resource "aws_nat_gateway" "nat_3" {
  allocation_id = aws_eip.nat_3.id
  subnet_id     = aws_subnet.private_subnets[2].id  
  tags = {
    Name = "NAT Gateway"
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
   Name = "Public Route Table"
 } 
 depends_on = [aws_internet_gateway.public_gateway]
}


resource "aws_route_table" "private" {
  count  = 3
  vpc_id = aws_vpc.public_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element([
      aws_nat_gateway.nat_1.id,
      aws_nat_gateway.nat_2.id,
      aws_nat_gateway.nat_3.id
    ], count.index)
  }
  tags = {
    Name = "Private-Subnet-RouteTable-${count.index}"
  }
  depends_on = [      aws_nat_gateway.nat_1,
      aws_nat_gateway.nat_2,
      aws_nat_gateway.nat_3]
}


resource "aws_route_table_association" "private" {
  count          = 3
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}