resource "aws_route_table" "public_route_table" {
  vpc_id = var.public_vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.public_gateway_id
  }
  route {
    cidr_block = var.vpc_cidr_block
    gateway_id = "local"
  }
  tags = {
    Name      = "Public Route Table"
    Project   = "weatherbug"
    ManagedBy = "terraform"
  }
}

resource "aws_route_table_association" "public" {
  count          = 3
  subnet_id      = var.public_subnet_ids[count.index]
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private" {
  count  = 3
  vpc_id = var.public_vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = var.nat_gateway_ids[count.index]
  }
  route {
    cidr_block = var.vpc_cidr_block
    gateway_id = "local"
  }
  tags = {
    Name      = "Private-Subnet-RouteTable-${count.index}"
    Project   = "weatherbug"
    ManagedBy = "terraform"
  }
}

resource "aws_route_table_association" "private-subnets" {
  count          = 3
  subnet_id      = var.private_subnet_ids[count.index]
  route_table_id = aws_route_table.private[count.index].id  
}