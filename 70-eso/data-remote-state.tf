data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# Datasource: EKS Cluster Auth 
data "aws_eks_cluster_auth" "cluster" {
  name = local.eks_cluster_name
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
