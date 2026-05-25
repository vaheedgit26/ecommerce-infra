# -------------------------
# EKS outputs
# -------------------------
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

# -------------------------
# EBS CSI outputs
# -------------------------
output "ebs_csi_addon_default_version" {
  description = "Default EBS CSI addon version compatible with the EKS cluster version"
  value       = data.aws_eks_addon_version.ebs_csi_default.version
}

output "ebs_csi_addon_latest_version" {
  description = "Latest available EBS CSI addon version for the current EKS cluster"
  value       = data.aws_eks_addon_version.ebs_csi_latest.version
}

output "ebs_csi_addon_arn" {
  description = "ARN of the installed EBS CSI addon"
  value       = aws_eks_addon.ebs_csi.arn
}

output "ebs_csi_addon_id" {
  description = "ID of the installed EBS CSI addon"
  value       = aws_eks_addon.ebs_csi.id
}
