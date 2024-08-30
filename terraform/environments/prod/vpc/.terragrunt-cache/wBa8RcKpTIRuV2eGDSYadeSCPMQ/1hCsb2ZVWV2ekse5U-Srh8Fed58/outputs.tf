output "vpc_id" {
  value       = aws_vpc.public_vpc.id
  description = "The ID of the VPC"
}
