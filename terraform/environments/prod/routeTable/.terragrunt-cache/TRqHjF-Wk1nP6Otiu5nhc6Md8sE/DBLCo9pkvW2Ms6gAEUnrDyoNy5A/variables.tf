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
