resource "aws_iam_role" "kms_manager_role" {
  name = "kms-manager-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "kms_manager_policy" {
  name        = "KMSManagerPolicy"
  description = "Policy for managing KMS keys"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "kms:*",
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "kms_manager_role_attach" {
  role       = aws_iam_role.kms_manager_role.name
  policy_arn = aws_iam_policy.kms_manager_policy.arn
}

resource "aws_kms_key" "eksEncryptionV2" {
  description = "Key for encrypting Kubernetes Secrets in EKS"
  bypass_policy_lockout_safety_check = true
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "AllowRoleToManageKMSKey",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::058264111371:role/kms-manager-role"
        },
        Action = [
          "kms:*",
        ],
        Resource = "*"
      },
      {
        Sid = "AllowGroupToManageKMSKey",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::058264111371:user/terraform"
        },
        Action = [
          "kms:*",
        ],
        Resource = "*"
      },
      {
        Sid = "AllowGroupToManageKMSKey",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::058264111371:root"
        },
        Action = [
          "kms:*",
        ],
        Resource = "*"
      },
      {
        Sid = "AllowEKSServiceToUseKey",
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        },
        Action = [
          "kms:*",
        ],
        Resource = "*"
      }
    ]
  })
  tags = {
    Name        = "EKSSecretsEncryptionKey2"
    Environment = "${var.environment_name}"
    ManagedBy   = "terraform"
  }
}
