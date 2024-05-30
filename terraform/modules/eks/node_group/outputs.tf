output "eks_node_group_id" {
  value       = aws_eks_node_group.simple_node_group.id
  description = "The ID of the EKS Node Group"
}

output "eks_node_group_arn" {
  value       = aws_eks_node_group.simple_node_group.arn
  description = "The ARN of the EKS Node Group"
}

