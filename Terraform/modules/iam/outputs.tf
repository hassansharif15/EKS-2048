output "cluster_role_arn" {
  description = "EKS cluster IAM role ARN"
  value       = aws_iam_role.cluster_role.arn
}

output "node_role_arn" {
  description = "EKS node group IAM role ARN"
  value       = aws_iam_role.node_role.arn
}
output "certmanager_role_arn" {
  description = "IAM role ARN for CertManager"
  value       = aws_iam_role.certmanager_role.arn
}

output "externaldns_role_arn" {
  description = "IAM role ARN for ExternalDNS"
  value       = aws_iam_role.externaldns_role.arn
}