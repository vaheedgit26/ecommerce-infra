locals {
  resource_name = "${var.project}-${var.env}"

  eks_cluster_name    = data.terraform_remote_state.eks.outputs.cluster_name
  eks_cluster_version = data.terraform_remote_state.eks.outputs.cluster_version
}
