locals {
  resource_name = "${var.project}-${var.env}"

  eks_oidc_provider_url = data.terraform_remote_state.eks.outputs.oidc_provider_url
  eks_oidc_provider_arn = data.terraform_remote_state.eks.outputs.oidc_provider_arn
}
