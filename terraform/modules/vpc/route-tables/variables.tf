variable "environment_name" {
  description = "Name of the environment"
  type        = string
}


variable "public_vpc_id" {
  description = "VPC id"
  type        = string
}

variable "public_gateway_id" {
  description = "public gateway id"
  type = string
}

variable "nat_gateway_ids" {
  description = "nat gateway id"
  type = list(string)
}

variable "public_subnet_ids" {
  description = "The IDs of the public subnets"
  type        = list(string)
}


variable "private_subnet_ids" {
  description = "The IDs of the private subnets"
  type        = list(string)
}


variable "vpc_cidr_block" {
  type        = string
  description = "Public Subnet CIDR values"
  default     = "10.0.0.0/16"
}