output "eks_encryption_key_arn" {
  value = aws_kms_key.eksEncryptionV2.arn
}

