output "ecr_repository_url" {
  value       = aws_ecr_repository.ecr_repo.repository_url
  description = "The URI of the ECR repository"
}


output "ecr_repository_arn" {
  value       = aws_ecr_repository.ecr_repo.arn
  description = "The URI of the ECR repository"
}