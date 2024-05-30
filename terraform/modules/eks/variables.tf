variable "environment_name" {
  description = "Name of the environment"
  type        = string
}


variable "region" {
  description = "AWS region to deploy to."
  type        = string
}


variable "ecr_repository_arn" {
  description = "AWS ECR repo arn EKS will be using."
  type        = string
}


variable "private_subnet_ids" {
  description = "The IDs of the private subnets"
  type        = list(string)
}


variable "eks_node_sg_id" {
  description = "The ID of the security group that allows web traffic"
  type        = string
}


variable "private_sg_id" {
  description = "private security group"
  type        = string
}


variable "eks_control_plane_sg_id" {
  description = "The ID of the EKS control plane security group"
  type        = string
}


variable "eks_cluster_name" {
  description = "The EKS cluster name"
  type        = string
}
