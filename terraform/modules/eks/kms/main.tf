data "aws_caller_identity" "current" {
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