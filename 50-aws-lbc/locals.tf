locals {
  resource_name = "${var.project}-${var.env}"

  eks_oidc_provider_url = data.terraform_remote_state.eks.outputs.oidc_provider_url
  eks_oidc_provider_arn = data.terraform_remote_state.eks.outputs.oidc_provider_arn

  eks_host  = data.terraform_remote_state.eks.outputs.cluster_endpoint
  eks_cluster_ca_certificate = data.terraform_remote_state.eks.outputs.cluster_ca
}
