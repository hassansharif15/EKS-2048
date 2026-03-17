variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}
variable "oidc_provider_arn" {
  description = "OIDC provider ARN from EKS module"
  type        = string
}

variable "oidc_provider_url" {
  description = "OIDC provider URL from EKS module"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN"
  type        = string
}

variable "oidc_provider_url" {
  description = "OIDC provider URL without https://"
  type        = string
}