resource "aws_kms_key" "eks_encryption" {
  description = "Key for encrypting Kubernetes Secrets in EKS"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Action    = "kms:*",
        Resource  = "*",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
      },
      {
        Effect    = "Allow",
        Action    = "kms:*",
        Resource  = "*",
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
  tags = {
    Name        = "EnvelopeEncryptionKey"
    Project     = "weatherbug"
    ManagedBy   = "terraform"
  }
}

resource "aws_eks_cluster" "main" {
  name     = "eks-cluster"
  role_arn = modules.iam.eks_cluster_role_arn
  version  = "1.29"

  vpc_config {
    subnet_ids         = module.vpc.private_subnets
    security_group_ids = [aws_security_group.eks_security_group.id]
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
    modules.iam.eks_cluster_policy,
    modules.iam.eks_vpc_resource_controller,
  ]
  tags = {
    Name        = "EnvelopeEncryptionKey"
    Project     = "weatherbug"
    ManagedBy   = "terraform"
  }
}