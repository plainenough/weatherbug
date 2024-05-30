variable "oidc_provider_arn" {
  description = "AWS ECR repo arn EKS will be using."
  type        = string
}


variable "oidc_issuer_url" {
  description = "The OIDC issuer URL for the EKS cluster"
  type        = string
}


variable "environment_name" {
  description = "Name of the environment"
  type        = string
  default     = "prod"
}


variable "ecr_repository_arn" {
  description = "AWS ECR repo arn EKS will be using."
  type        = string
}


variable "private_subnet_ids" {
  description = "The IDs of the private subnets"
  type        = list(string)
}

variable "eks_cluster_name" {
  description = "EKS cluster name to attach the nodegroup to"
  type        = string
}