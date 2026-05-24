locals {
  resource_name = "${var.project}-${var.env}"

  eks_oidc_provider_url_ = data.terraform_remote_state.eks.outputs.oidc_provider_url
  oidc_provider_arn = data.terraform_remote_state.eks.outputs.oidc_provider_arn
}
