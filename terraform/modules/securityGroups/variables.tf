variable "environment_name" {
  description = "Name of the environment"
  type        = string
}


variable "public_vpc_id" {
  description = "VPC id"
  type        = string
}

variable "private_subnet_cidrs" {
  description = "Ciders for private subnets"
  type = list(string)
}