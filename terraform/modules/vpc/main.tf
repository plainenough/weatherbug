resource "aws_vpc" "public_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "VPC-${var.region}-${var.environment_name}"
    Project     = "weatherbug"
    ManagedBy   = "terraform"
  }
}


resource "aws_subnet" "public_subnets" {
  count      = length(var.public_subnets_cidr)
  vpc_id     = aws_vpc.public_vpc.id
  cidr_block = var.public_subnets_cidr[count.index]
  availability_zone = "${var.region}${var.azs[count.index]}"
  tags = {
    Name = "Public-${var.environment_name}-${var.region}-${var.azs[count.index]}"
    Project     = "weatherbug"
    ManagedBy   = "terraform"
  }
}


resource "aws_subnet" "private_subnets" {
  count      = length(var.private_subnets_cidr)
  vpc_id     = aws_vpc.public_vpc.id
  cidr_block = var.private_subnets_cidr[count.index]
  availability_zone = "${var.region}${var.azs[count.index]}"
  tags = {
    Name = "Private-${var.environment_name}-${var.region}-${var.azs[count.index]}"
    Project     = "weatherbug"
    ManagedBy   = "terraform"    
  }
}


# This assumes that subnets order is maintained throughout creation.
resource "aws_eip" "nat_a" {
  vpc = true
  tags = {
    Name = "EIP for NAT Gateway AZ-a"
    Project     = "weatherbug"
    ManagedBy   = "terraform"
  }
}


resource "aws_eip" "nat_b" {
  vpc = true
  tags = {
    Name = "EIP for NAT Gateway AZ-b"
    Project     = "weatherbug"
    ManagedBy   = "terraform"
  }
}


resource "aws_eip" "nat_c" {
  vpc = true
  tags = {
    Name = "EIP for NAT Gateway AZ-c"
    Project     = "weatherbug"
    ManagedBy   = "terraform"
  }
}


resource "aws_internet_gateway" "public_gateway" {
  vpc_id = aws_vpc.public_vpc.id
  tags = {
    Name = "Project VPC IG"
    Project     = "weatherbug"
    ManagedBy   = "terraform"
 }
}


# This assumes that subnets order is maintained throughout creation.
resource "aws_nat_gateway" "nat_1" {
  allocation_id = aws_eip.nat_a.id
  subnet_id     = aws_subnet.private_subnets[0].id  
  tags = {
    Name = "NAT Gateway 1"
    Project     = "weatherbug"
    ManagedBy   = "terraform"
  }
  depends_on = [aws_internet_gateway.public_gateway, aws_eip.nat_a]
}


resource "aws_nat_gateway" "nat_2" {
  allocation_id = aws_eip.nat_b.id
  subnet_id     = aws_subnet.private_subnets[1].id  
  tags = {
    Name = "NAT Gateway 2"
    Project     = "weatherbug"
    ManagedBy   = "terraform"
  }
  depends_on = [aws_internet_gateway.public_gateway, aws_eip.nat_b]
}


resource "aws_nat_gateway" "nat_3" {
  allocation_id = aws_eip.nat_3.id
  subnet_id     = aws_subnet.private_subnets[2].id  
  tags = {
    Name = "NAT Gateway 3"
    Project     = "weatherbug"
    ManagedBy   = "terraform"
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
    Project     = "weatherbug"
    ManagedBy   = "terraform"
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
    Project     = "weatherbug"
    ManagedBy   = "terraform"
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


resource "aws_security_group" "external_web_traffic_sg" {
  name        = "external_web_traffic_sg"
  description = "Security group for allowing web traffic"
  vpc_id      = aws_vpc.public_vpc.id

  tags = {
    Name = "ExternalWebTrafficSecurityGroup"
    Project     = "weatherbug"
    ManagedBy   = "terraform"
  }
  depends_on = [ aws_vpc.public_vpc ]
}


resource "aws_security_group_rule" "allow_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.external_web_traffic_sg.id
  description       = "Allow inboud HTTP traffic"
}


resource "aws_security_group_rule" "allow_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]  # Allows traffic from any IP address
  security_group_id = aws_security_group.external_web_traffic_sg.id
  description       = "Allow inbound HTTPS traffic"
}


resource "aws_security_group_rule" "allow_outbound_traffic" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.external_web_traffic_sg.id
  description       = "Allow all outbound traffic"
}


resource "aws_security_group" "eks_node_sg" {
  name        = "eks-node-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = aws_vpc.public_vpc.id

  tags = {
    Name = "eks-worker-node-security-group"
  }
  depends_on = [ aws_vpc.public_vpc ]
}


resource "aws_security_group_rule" "eks_node_ingress_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.eks_node_sg.id
  self              = true
  description       = "Allow node to communicate with itself"
}


resource "aws_security_group_rule" "eks_node_egress_self" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.eks_node_sg.id
  self              = true
  description       = "Allow node to communicate with itself"
}

