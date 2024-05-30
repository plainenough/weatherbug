resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = var.public_vpc_id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = "${var.region}${var.azs[count.index]}"
  tags = {
    Name      = "Public-${var.environment_name}-${var.region}-${var.azs[count.index]}"
    Project   = "weatherbug"
    ManagedBy = "terraform"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
  }
}


resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = var.public_vpc_id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = "${var.region}${var.azs[count.index]}"
  tags = {
    Name      = "Private-${var.environment_name}-${var.region}-${var.azs[count.index]}"
    Project   = "weatherbug"
    ManagedBy = "terraform"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
  }
}