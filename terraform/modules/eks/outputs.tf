output "eks_cluster_arn" {
  value       = aws_eks_cluster.main.arn
  description = "The ARN of the EKS Cluster"
}


output "eks_cluster_id" {
  value       = aws_eks_cluster.main.id
  description = "The ID of the EKS Cluster"
}


output "eks_cluster_endpoint" {
  value       = aws_eks_cluster.main.endpoint
  description = "The endpoint for kubectl to connect to the EKS cluster"
}


output "eks_node_group_arn" {
  value       = module.node_group.eks_node_group_arn
  description = "The ARN of the EKS Node Group"
}


output "eks_node_group_id" {
  value       = module.node_group.eks_node_group_id
  description = "The ID of the EKS Node Group"
}

