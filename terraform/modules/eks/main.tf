data "aws_caller_identity" "current" {
}

module "iam" {
  source = "../../modules/iam"
  environment_name = var.environment_name
}

module "vpc" {
  source = "../../modules/vpc"
  region = var.region
  environment_name = var.environment_name
}

module "ecr" {
  source = "../../modules/ecr"
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
    security_group_ids      = [module.vpc.eks_node_sg_id, module.vpc.eks_control_plane_sg_id, module.vpc.private_sg_id]
    endpoint_private_access = true
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
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = module.vpc.private_subnet_ids
  instance_types = ["t2.micro"]
  ami_type = "AL2_x86_64"  # Amazon Linux 2
  scaling_config {
    desired_size = 3
    min_size     = 1
    max_size     = 5
  }
  tags = {
    Name        = "EKS Simple Node Group"
    Environment = "${var.environment_name}"
    Project     = "weatherbug"
    ManagedBy   = "terraform"
  }
  lifecycle {
    create_before_destroy = true
  }
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



data "external" "oidc_thumbprint" {
  program = ["bash", "${path.module}/fetch-thumbprint.sh", "${data.aws_eks_cluster.main.identity[0].oidc[0].issuer}"]
}


resource "aws_iam_openid_connect_provider" "oidc_provider" {
  url             = data.aws_eks_cluster.main.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.external.oidc_thumbprint.result["thumbprint"]]

  depends_on = [
    aws_eks_cluster.main
  ]
}


resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = aws_iam_openid_connect_provider.oidc_provider.arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${data.aws_eks_cluster.main.identity[0].oidc[0].issuer}:sub" = "system:serviceaccount:kube-system:aws-node"
        }
      }
    },
    {
     Effect = "Allow"
       Principal = {
         Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "ecr_access" {
  name        = "EcrEksAccess"
  description = "Allows EKS nodes to push and pull from ECR"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
        ],
        Resource = module.ecr.ecr_repository_arn
      }
    ]
  })
  tags = {
    Name      = "EcrEksAccess"
    Project   = "weatherbug"
    ManagedBy = "terraform"
  }
}


resource "aws_iam_role_policy_attachment" "eks_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}


resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}


resource "aws_iam_role_policy_attachment" "eks_ssm_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "ecr_push_pull" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = aws_iam_policy.ecr_access.arn
}

