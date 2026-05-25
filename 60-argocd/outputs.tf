output "eks_cluster_name" {
  value = local.eks_cluster_name
}

output "eks_cluster_endpoint" {
  value = local.eks_host
}

output "eks_oidc_provider_url" {
  value = data.terraform_remote_state.eks.outputs.oidc_provider_url
}

output "eks_oidc_provider_arn" {
  value = data.terraform_remote_state.eks.outputs.oidc_provider_arn
}
