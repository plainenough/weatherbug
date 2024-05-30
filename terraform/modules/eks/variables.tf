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