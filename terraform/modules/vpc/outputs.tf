output "vpc_id" {
  value       = aws_vpc.public_vpc.id
  description = "The ID of the VPC"
}


output "public_subnet_ids" {
  value       = module.subnets.public_subnet_ids
  description = "The IDs of the public subnets"
}


output "private_subnet_ids" {
  value       = module.subnets.private_subnet_ids
  description = "The IDs of the private subnets"
}


output "nat_gateway_ids" {
  value = [
    aws_nat_gateway.nat_gateways["nat_1"].id,
    aws_nat_gateway.nat_gateways["nat_2"].id,
    aws_nat_gateway.nat_gateways["nat_3"].id
  ]
  description = "The IDs of the NAT Gateways"
}


output "internet_gateway_id" {
  value       = aws_internet_gateway.public_gateway.id
  description = "The ID of the Internet Gateway"
}


output "nat_eips" {
  value = {
    "nat_a" = aws_eip.nat_a.public_ip,
    "nat_b" = aws_eip.nat_b.public_ip,
    "nat_c" = aws_eip.nat_c.public_ip
  }
  description = "The public IPs of the NAT Gateways"
}


output "web_traffic_security_group_id" {
  value       = module.security-groups.external_web_traffic_sg_id
  description = "The ID of the security group that allows web traffic"
}


output "eks_node_sg_id" {
  value       = module.security-groups.eks_node_sg_id
  description = "The ID of the security group that allows web traffic"
}

output "private_sg_id" {
  value = module.security-groups.private_sg_id
  description = "private security group"
}