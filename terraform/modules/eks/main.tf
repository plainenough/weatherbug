module "node_group" {
  source = "./node_group"
  environment_name = var.environment_name
  eks_cluster_name = aws_eks_cluster.main.name
  ecr_repository_arn = var.ecr_repository_arn
  oidc_provider_arn = aws_iam_openid_connect_provider.oidc_provider.arn
  oidc_issuer_url = data.aws_eks_cluster.main.identity[0].oidc[0].issuer
  private_subnet_ids = var.private_subnet_ids
}


module "kms" {
  source = "./kms"
  environment_name = var.environment_name
}


resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })
  tags = {
    Name      = "eks-cluster-role"
    Project   = "weatherbug"
    ManagedBy = "terraform"
  }
}


resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}


resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController" # This policy is required to allow EKS to manage network resources for the cluster
}


resource "aws_eks_cluster" "main" {
  name     = "${var.region}-eks-${var.environment_name}"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.29"
  vpc_config {
    subnet_ids              = var.private_subnet_ids
    security_group_ids      = [var.eks_node_sg_id, var.eks_control_plane_sg_id, var.private_sg_id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }
  encryption_config {
    provider {
      key_arn = module.kms.eks_encryption_key_arn
    }
    resources = ["secrets"]
  }
  depends_on = [
    aws_iam_role.eks_cluster_role,
  ]
  tags = {
    Name        = "${var.region}-eks-${var.environment_name}"
    Environment = "${var.environment_name}"
    Project     = "weatherbug"
    ManagedBy   = "terraform"
  }
}


data "external" "oidc_thumbprint" {
  program = ["bash", "${path.module}/scripts/fetch-thumbprint.sh", "${data.aws_eks_cluster.main.identity[0].oidc[0].issuer}"]
}


resource "aws_iam_openid_connect_provider" "oidc_provider" {
  url             = data.aws_eks_cluster.main.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.external.oidc_thumbprint.result["thumbprint"]]
  depends_on = [
    aws_eks_cluster.main
  ]
}


resource "aws_eks_addon" "kubeproxy_addon" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "kube-proxy"
}


resource "aws_eks_addon" "cni_addon" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "vpc-cni"
}


data "aws_ami" "eks_worker" {
  most_recent = true
  owners      = ["602401143452"]  
  filter {
    name   = "name"
    values = ["amazon-eks-node-1.29-v*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}


data "aws_eks_cluster" "main" {
  name = aws_eks_cluster.main.name
}







