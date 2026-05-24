# --------------------------------------------------------------------
# Reference the Remote State from VPC Project
# --------------------------------------------------------------------
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = var.remote_state_s3_bucket                               # Name of the remote S3 bucket where the VPC state is stored
    key    = "${var.project}/${var.env}/vpc/terraform.tfstate"        # Path to the VPC tfstate file within the bucket
    region = var.region                                               # Region where the S3 bucket and DynamoDB table exist
  }
}

# --------------------------------------------------------------------
# Reference the Remote State from EKS Project
# --------------------------------------------------------------------
data "terraform_remote_state" "eks" {
  backend = "s3"

  config = {
    bucket = var.remote_state_s3_bucket                               # Name of the remote S3 bucket where the EKS state is stored
    key    = "${var.project}/${var.env}/eks/terraform.tfstate"        # Path to the EKS tfstate file within the bucket
    region = var.region                                               # Region where the S3 bucket and DynamoDB table exist
  }
}

# --------------------------------------------------------------------
# Output the VPC id
# --------------------------------------------------------------------
output "vpc_id" {
  value = data.terraform_remote_state.vpc.outputs.vpc_id
}

# --------------------------------------------------------------------
# Output the EKS cluster name
# --------------------------------------------------------------------
output "eks_cluster_name" {
  value = data.terraform_remote_state.eks.outputs.cluster_name
}

# --------------------------------------------------------------------
# Output the EKS cluster endpoint
# --------------------------------------------------------------------
output "eks_cluster_endpoint" {
  value = data.terraform_remote_state.eks.outputs.cluster_endpoint
}

# --------------------------------------------------------------------
# Output the EKS cluster ca
# --------------------------------------------------------------------
output "eks_cluster_ca" {
  value = data.terraform_remote_state.eks.outputs.cluster_ca
}

# --------------------------------------------------------------------
# Output the EKS cluster OIDC URL
# --------------------------------------------------------------------
output "eks_oidc_provider_url" {
  value = data.terraform_remote_state.eks.outputs.oidc_provider_url
}

# --------------------------------------------------------------------
# Output the EKS cluster OIDC ARN
# --------------------------------------------------------------------
output "eks_oidc_provider_arn" {
  value = data.terraform_remote_state.eks.outputs.oidc_provider_arn
}
