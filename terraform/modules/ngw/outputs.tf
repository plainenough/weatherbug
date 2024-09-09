output "nat_gateways" {
  value       = aws_nat_gateway.nat_gateways[*].id
  description = "NAT Gateway IDs"
}
