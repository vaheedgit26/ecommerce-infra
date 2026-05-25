# EKS outputs
output "eks_cluster_name"    { value = local.eks_cluster_name }
output "eks_cluster_version" { value = local.eks_cluster_version }

# Metrics Server outputs
output "metrics_server_eksaddon_default_version" {
  value = data.aws_eks_addon_version.metrics_server_default.version
}

output "metrics_server_eksaddon_lastest_version" {
  value = data.aws_eks_addon_version.metrics_server_latest.version
}

output "metrics_server_agent_eksaddon_arn" {
  value = aws_eks_addon.metrics_server.arn
}  

output "metrics_server_agent_eksaddon_id" {
  value = aws_eks_addon.metrics_server.id
}
