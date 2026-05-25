# Datasource: To get default EKS addon version compatible with EKS cluster version
data "aws_eks_addon_version" "metrics_server_default" {
  addon_name         = "metrics-server"
  kubernetes_version = local.eks_cluster_version
}

# Datasource: To get latest EKS addon version compatible with EKS cluster version
data "aws_eks_addon_version" "metrics_server_latest" {
  addon_name         = "metrics-server"
  kubernetes_version = local.eks_cluster_version
  most_recent        = true
}

# EKS Addon
resource "aws_eks_addon" "metrics_server" {
  cluster_name                = local.eks_cluster_name
  addon_name                  = "metrics-server"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  # Use the latest EKS addon version compatible with the cluster's Kubernetes version
  addon_version               = data.aws_eks_addon_version.metrics_server_latest.version

  tags = {
    Name        = "${local.resource_name}-metrics-server"
    Project     = var.project
    Environment = var.env
  }

}
