output "cluster_role_arn" {
  description = "EKS cluster IAM role ARN"
  value       = aws_iam_role.cluster_role.arn
}

output "node_role_arn" {
  description = "EKS node group IAM role ARN"
  value       = aws_iam_role.node_role.arn
}

module "iam" {
  source            = "./modules/iam"
  project_name      = var.project_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
}

output "externaldns_role_arn" {
  description = "IAM role ARN for ExternalDNS"
  value       = aws_iam_role.externaldns_role.arn
}