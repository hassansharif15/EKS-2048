variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID from the VPC module"
  type        = string
}

variable "private_subnets" {
  description = "Private subnet IDs from the VPC module"
  type        = list(string)
}

variable "cluster_role_arn" {
  description = "IAM role ARN for the EKS cluster"
  type        = string
}

variable "node_role_arn" {
  description = "IAM role ARN for the worker nodes"
  type        = string
}