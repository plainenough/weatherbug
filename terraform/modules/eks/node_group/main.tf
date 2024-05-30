resource "aws_eks_node_group" "simple_node_group" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "simple-node-group"
  node_role_arn   = iam.eks_node_role_arn
  subnet_ids      = var.private_subnet_ids
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
  depends_on = [
    module.iam.eks_node_policy,
    aws_eks_cluster.main
  ]
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = var.oidc_provider_arn
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
        Resource = var.ecr_repository_arn
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