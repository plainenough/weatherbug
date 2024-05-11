variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = ["10.0.0.0/28", "10.0.0.16/28", "10.0.0.32/28"]
}


variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDR values"
  default     = ["10.0.0.48/28", "10.0.0.64/28", "10.0.0.80/28"]
}


variable "azs" {
  type        = list(string)
  description = "Availability Zones"
  default     = ["a", "b", "c"]
}


variable "environment_name" {
  description = "Name of the environment"
  type        = string
  default     = "deployment-test"
}


variable "region" {
  description = "AWS region to deploy to."
  type        = string
  default     = "us-east-2"
}

