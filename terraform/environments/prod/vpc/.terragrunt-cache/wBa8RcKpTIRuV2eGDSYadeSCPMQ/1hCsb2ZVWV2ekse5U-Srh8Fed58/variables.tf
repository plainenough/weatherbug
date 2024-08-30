variable "environment_name" {
  description = "Name of the environment"
  type        = string
}


variable "region" {
  description = "AWS region to deploy to."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for vpc"
  type        = string
}
