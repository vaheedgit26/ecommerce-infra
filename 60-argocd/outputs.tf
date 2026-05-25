output "eks_cluster_name" {
  value = local.eks_cluster_name
}

output "eks_cluster_endpoint" {
  value = local.eks_host
}

output "eks_oidc_provider_url" {
  value = local.eks_oidc_provider_url
}

output "eks_oidc_provider_arn" {
  value = local.eks_oidc_provider_arn
}
