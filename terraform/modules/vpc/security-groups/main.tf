resource "aws_security_group" "external_web_traffic_sg" {
  name        = "external_web_traffic_sg"
  description = "Security group for allowing web traffic"
  vpc_id      = var.public_vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow inbound HTTP traffic"
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow inbound HTTPS traffic"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
  tags = {
    Name        = "${var.environment_name}-external-web-sg"
    Environment = var.environment_name
    Project     = "weatherbug"
    ManagedBy   = "terraform"
  }
}


resource "aws_security_group" "eks_node_sg" {
  name        = "eks-node-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.public_vpc_id
  tags = {
    Name        = "eks-worker-node-security-group"
    Environment = var.environment_name
    Project     = "weatherbug"
    ManagedBy   = "terraform"
  }
}

resource "aws_security_group_rule" "eks_node_self_ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.eks_node_sg.id
  self              = true
  description       = "Allow node to communicate with itself"
}

resource "aws_security_group_rule" "eks_node_public_ingress" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_node_sg.id
  source_security_group_id = aws_security_group.public_sg.id
  description              = "Allow traffic from public security group"
}

resource "aws_security_group_rule" "eks_node_private_ingress" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_node_sg.id
  source_security_group_id = aws_security_group.private_sg.id
  description              = "Allow traffic from private security group"
}

resource "aws_security_group_rule" "eks_node_self_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.eks_node_sg.id
  self              = true
  description       = "Allow node to communicate with itself"
}

resource "aws_security_group_rule" "eks_node_efs_egress" {
  type              = "egress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  security_group_id = aws_security_group.eks_node_sg.id
  cidr_blocks       = var.private_subnet_cidrs
  description       = "Allow EFS access from private subnets"
}


resource "aws_security_group" "eks_control_plane_sg" {
  name        = "eks-control-plane-sg"
  description = "Security group for EKS control plane"
  vpc_id      = var.public_vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
  tags = {
    Name        = "eks-control-plane-security-group"
    Environment = var.environment_name
    Project     = "weatherbug"
    ManagedBy   = "terraform"
  }
}

resource "aws_security_group_rule" "eks_control_plane_ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.eks_control_plane_sg.id
  source_security_group_id = aws_security_group.eks_node_sg.id
  description       = "Allow traffic from the worker nodes"
}

resource "aws_security_group_rule" "eks_control_plane_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.eks_control_plane_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic"
}


resource "aws_security_group" "public_sg" {
  name        = "${var.environment_name}-public-sg"
  description = "Security group for public subnet"
  vpc_id      = var.public_vpc_id
  tags = {
    Name        = "${var.environment_name}-public-sg"
    Environment = var.environment_name
    Project     = "weatherbug"
    ManagedBy   = "terraform"
  }
}


resource "aws_security_group_rule" "public_sg_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public_sg.id
  description       = "Allow HTTP traffic from the internet"
}


resource "aws_security_group_rule" "public_sg_ingress_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.public_sg.id
  self              = true
  description       = "Allow all traffic within the public subnet"
}


resource "aws_security_group_rule" "public_sg_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public_sg.id
  description       = "Allow all outbound traffic"
}


resource "aws_security_group" "private_sg" {
  name        = "${var.environment_name}-private-sg"
  description = "Security group for private subnet"
  vpc_id      = var.public_vpc_id
  tags = {
    Name        = "${var.environment_name}-private-sg"
    Environment = var.environment_name
    Project     = "weatherbug"
    ManagedBy   = "terraform"
  }
}

resource "aws_security_group_rule" "private_sg_ingress_from_public" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.private_sg.id
  source_security_group_id = aws_security_group.public_sg.id
  description              = "Allow all traffic from public subnet"
}

resource "aws_security_group_rule" "private_sg_ingress_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.private_sg.id
  self              = true
  description       = "Allow all traffic from private subnet"
}

resource "aws_security_group_rule" "private_sg_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.private_sg.id
  description       = "Allow all outbound traffic"
}
