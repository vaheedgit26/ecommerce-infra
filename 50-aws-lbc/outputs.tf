# Output the VPC id
output "vpc_id" {
  value = local.vpc_id
}

# Output the EKS cluster name
output "eks_cluster_name" {
  value = local.eks_cluster_name
}

# Output the EKS cluster endpoint
output "eks_cluster_endpoint" {
  value = local.eks_cluster_endpoint
}

# Output the EKS cluster ca
output "eks_cluster_ca" {
  value = local.eks_cluster_ca
}

# Output the EKS cluster OIDC URL
output "eks_oidc_provider_url" {
  value = local.eks_oidc_provider_url
}

# Output the EKS cluster OIDC ARN
output "eks_oidc_provider_arn" {
  value = local.eks_oidc_provider_arn
}
