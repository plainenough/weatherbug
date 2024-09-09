output "external_web_traffic_sg_id" {
  description = "The ID of the external web traffic security group"
  value       = aws_security_group.external_web_traffic_sg.id
}

output "eks_node_sg_id" {
  description = "The ID of the EKS worker nodes security group"
  value       = aws_security_group.eks_node_sg.id
}

output "eks_control_plane_sg_id" {
  description = "The ID of the EKS control plane security group"
  value       = aws_security_group.eks_control_plane_sg.id
}

output "public_sg_id" {
  description = "The ID of the public subnet security group"
  value       = aws_security_group.public_sg.id
}

output "private_sg_id" {
  description = "The ID of the private subnet security group"
  value       = aws_security_group.private_sg.id
}