output "cluster_role_arn" {
  description = "EKS cluster IAM role ARN"
  value       = aws_iam_role.cluster_role.arn
}

output "node_role_arn" {
  description = "EKS node group IAM role ARN"
  value       = aws_iam_role.node_role.arn
}