output "vpc_id" {
  value       = aws_vpc.public_vpc.id
  description = "The ID of the VPC"
}


output "public_subnet_ids" {
  value       = aws_subnet.public_subnets[*].id
  description = "The IDs of the public subnets"
}


output "private_subnet_ids" {
  value       = aws_subnet.private_subnets[*].id
  description = "The IDs of the private subnets"
}


output "nat_gateway_ids" {
  value = [
    aws_nat_gateway.nat_1.id,
    aws_nat_gateway.nat_2.id,
    aws_nat_gateway.nat_3.id
  ]
  description = "The IDs of the NAT Gateways"
}


output "internet_gateway_id" {
  value       = aws_internet_gateway.public_gateway.id
  description = "The ID of the Internet Gateway"
}


output "public_route_table_id" {
  value       = aws_route_table.public_route_table.id
  description = "The ID of the public route table"
}


output "private_route_table_ids" {
  value       = aws_route_table.private[*].id
  description = "The IDs of the private route tables"
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
  value       = aws_security_group.external_web_traffic_sg.id
  description = "The ID of the security group that allows web traffic"
}


output "eks_node_sg" {
  value       = aws_security_group.eks_node_sg.id
  description = "The ID of the security group that allows web traffic"
}