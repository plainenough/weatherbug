variable "oidc_provider_arn" {
  description = "AWS ECR repo arn EKS will be using."
  type        = string
}

variable "environment_name" {
  description = "Name of the environment"
  type        = string
  default     = "prod"
}