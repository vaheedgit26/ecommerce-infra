output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_version" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_version
}

output "cluster_endpoint" {
  description = "Endpoint for the EKS cluster API server"
  value       = module.eks.cluster_endpoint
}

output "cluster_ca" {
  description = "Base64 encoded certificate authority data for the EKS cluster"
  value       = module.eks.cluster_ca
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC Provider for IRSA"
  value       = module.eks.oidc_provider_arn
}

output "oidc_provider_url" {
  description = "URL of the OIDC Provider for IRSA"
  value       = module.eks.oidc_provider_url
}

output "node_group_arn" {
  description = "ARN of the EKS Node Group"
  value       = module.eks.node_group_arn
}

output "cluster_security_group_id" {
  description = "Security group ID automatically created by EKS and attached to managed nodes"
  value       = module.eks.cluster_security_group_id
}

output "to_configure_kubectl" {
  description = "Command to update local kubeconfig to connect to the EKS cluster"
  value       = "aws eks --region ${var.region} update-kubeconfig --name ${module.eks.cluster_name}"
}
