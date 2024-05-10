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


output "kms_key_arn" {
  value       = aws_kms_key.eks_encryption.arn
  description = "The ARN of the KMS Key used for encrypting Kubernetes Secrets"
}


output "eks_node_group_arn" {
  value       = aws_eks_node_group.simple_node_group.arn
  description = "The ARN of the EKS Node Group"
}


output "eks_node_group_id" {
  value       = aws_eks_node_group.simple_node_group.id
  description = "The ID of the EKS Node Group"
}

# Comment this just in case we need it for later. I plan on using awscli to generate this.
#output "eks_cluster_kubeconfig" {
#  value = <<KUBECONFIG
#apiVersion: v1
#clusters:
#- cluster:
#    server: ${aws_eks_cluster.main.endpoint}
#    certificate-authority-data: ${aws_eks_cluster.main.certificate_authority[0].data}
#  name: eks
#contexts:
#- context:
#    cluster: eks
#    user: "aws"
#  name: aws
#current-context: aws
#users:
#- name: "aws"
#  user:
#    exec:
#      apiVersion: client.authentication.k8s.io/v1alpha1
#      command: aws
#      args:
#        - eks
#        - get-token
#        - --cluster-name
#        - "${aws_eks_cluster.main.name}"
#      # Uncomment the following line to specify a profile name
#      # env:
#      #   - name: AWS_PROFILE
#      #     value: "your-profile-name"
#KUBECONFIG
#  description = "Kubeconfig for connecting to the EKS cluster using kubectl"
#}

