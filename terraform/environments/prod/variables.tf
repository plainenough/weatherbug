variable "environment_name" {
  description = "Name of the environment"
  type        = string
  default     = "prod"
}


variable "region" {
  description = "AWS region to deploy to."
  type        = string
  default     = "us-east-2"
}


