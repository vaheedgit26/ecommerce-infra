locals {
  resource_name = "${var.project}-${var.env}"

  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  eks_oidc_provider_url = data.terraform_remote_state.eks.outputs.oidc_provider_url
  eks_oidc_provider_arn = data.terraform_remote_state.eks.outputs.oidc_provider_arn

  eks_host  = data.terraform_remote_state.eks.outputs.cluster_endpoint
  eks_token = data.aws_eks_cluster_auth.cluster.token
  eks_cluster_ca_certificate = data.terraform_remote_state.eks.outputs.cluster_ca

  eks_cluster_name = data.terraform_remote_state.eks.outputs.cluster_name
}
