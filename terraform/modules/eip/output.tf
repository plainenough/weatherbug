output "eips" {
  value       = aws_eip.nat[*].id
  description = "The EIPs for our nat gateways"
}
