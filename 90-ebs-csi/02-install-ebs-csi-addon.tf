# Datasource: Get the default EBS CSI addon version compatible with EKS version
data "aws_eks_addon_version" "ebs_csi_default" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = aws_eks_cluster.main.version
}

# Datasource: Get the latest available EBS CSI addon version
data "aws_eks_addon_version" "ebs_csi_latest" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = aws_eks_cluster.main.version
  most_recent        = true
}

# Resource: Install EBS CSI Driver addon
resource "aws_eks_addon" "ebs_csi" {
  depends_on = [
    aws_iam_role.ebs_csi_iam_role,
    aws_iam_role_policy_attachment.ebs_csi_managed_policy_attach
  ]

  cluster_name                = local.eks_cluster_name
  addon_name                  = "aws-ebs-csi-driver"
  addon_version               = data.aws_eks_addon_version.ebs_csi_latest.version

  service_account_role_arn    = aws_iam_role.ebs_csi_role.arn

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = {
    Name        = "${local.resource_name}-aws-ebs-csi-addon"
    Project     = var.Project
    Environment = var.env
    Component   = "Amazon EBS CSI Driver"
  }
}
