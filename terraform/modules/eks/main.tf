data "aws_caller_identity" "current" {
}

module "iam" {
  source = "../../modules/iam"
  environment_name = var.environment_name
}

module "vpc" {
  source = "../../modules/vpc"
  environment_name = var.environment_name
}

resource "aws_kms_key" "eks_encryption" {
  description = "Key for encrypting Kubernetes Secrets in EKS"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "kms:*",
        Resource = "*",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
      },
      {
        Effect = "Allow",
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*",
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
  tags = {
    Name        = "EnvelopeEncryptionKey"
    Environment = "${var.environment_name}"
    Project     = "weatherbug"
    ManagedBy   = "terraform"
  }
}

resource "aws_eks_cluster" "main" {
  name     = "${var.region}-eks-${var.environment_name}"
  role_arn = module.iam.eks_cluster_role_arn
  version  = "1.29"
  vpc_config {
    subnet_ids              = module.vpc.private_subnet_ids
    security_group_ids      = [module.vpc.eks_node_sg]
    endpoint_private_access = false
    endpoint_public_access  = true
  }
  encryption_config {
    provider {
      key_arn = aws_kms_key.eks_encryption.arn
    }
    resources = ["secrets"]
  }
  depends_on = [
    module.iam.eks_cluster_policy,
    module.iam.eks_vpc_resource_controller,
  ]
  tags = {
    Name        = "${var.region}-eks-${var.environment_name}"
    Environment = "${var.environment_name}"
    Project     = "weatherbug"
    ManagedBy   = "terraform"
  }
}


resource "aws_eks_node_group" "simple_node_group" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "simple-node-group"
  node_role_arn   = module.iam.eks_node_role_arn
  subnet_ids      = module.vpc.private_subnet_ids
  scaling_config {
    desired_size = 3
    min_size     = 1
    max_size     = 5
  }
  instance_types = ["t3.small"]
  ami_type       = "AL2_x86_64"
  disk_size      = 20
  tags = {
    Name        = "EKS Simple Node Group"
    Environment = "${var.environment_name}"
    Project     = "weatherbug"
    ManagedBy   = "terraform"
  }
  remote_access {
    ec2_ssh_key               = "eks-custom-key"
    source_security_group_ids = [module.vpc.eks_node_sg]
  }
}