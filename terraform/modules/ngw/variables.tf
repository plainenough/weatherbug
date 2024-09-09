variable "eips" {
  type        = list(string)
  description = "Elastic Ip Ids"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnets"
}
