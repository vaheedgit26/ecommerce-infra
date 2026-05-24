output "eks_oidc_provider_url" {
  value = data.terraform_remote_state.eks.outputs.oidc_provider_url
}

output "eks_oidc_provider_arn" {
  value = data.terraform_remote_state.eks.outputs.oidc_provider_arn
}
