# Output the VPC id
output "vpc_id" {
  value = data.terraform_remote_state.vpc.outputs.vpc_id
}

# Output the EKS cluster name
output "eks_cluster_name" {
  value = data.terraform_remote_state.eks.outputs.cluster_name
}

# Output the EKS cluster endpoint
output "eks_cluster_endpoint" {
  value = data.terraform_remote_state.eks.outputs.cluster_endpoint
}

# Output the EKS cluster ca
output "eks_cluster_ca" {
  value = data.terraform_remote_state.eks.outputs.cluster_ca
}

# Output the EKS cluster OIDC URL
output "eks_oidc_provider_url" {
  value = data.terraform_remote_state.eks.outputs.oidc_provider_url
}

# Output the EKS cluster OIDC ARN
output "eks_oidc_provider_arn" {
  value = data.terraform_remote_state.eks.outputs.oidc_provider_arn
}
