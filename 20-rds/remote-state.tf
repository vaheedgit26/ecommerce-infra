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
# Reference the Remote State from BASTION Project
# --------------------------------------------------------------------
data "terraform_remote_state" "bastion" {
  backend = "s3"

  config = {
    bucket = var.remote_state_s3_bucket                               # Name of the remote S3 bucket where the BASTION state is stored
    key    = "${var.project}/${var.env}/bastion/terraform.tfstate"    # Path to the BASTION tfstate file within the bucket
    region = var.region                                               # Region where the S3 bucket and DynamoDB table exist
  }
}

# --------------------------------------------------------------------
# Reference the Remote State from SECRETS-MANAGER Project
# --------------------------------------------------------------------
data "terraform_remote_state" "secrets-manager" {
  backend = "s3"

  config = {
    bucket = var.remote_state_s3_bucket                                           # Name of the remote S3 bucket where the SECRETS-MANAGER state is stored
    key    = "${var.project}/${var.env}/secrets-manager/terraform.tfstate"        # Path to the VPC tfstate file within the bucket
    region = var.region                                                           # Region where the S3 bucket and DynamoDB table exist
  }
}

# --------------------------------------------------------------------
# Output the AZ from the remote VPC state
# --------------------------------------------------------------------
output "az" {
  value = data.terraform_remote_state.vpc.outputs.availability_zones[0]
}

# --------------------------------------------------------------------
# Output the EKS cluster security group id
# --------------------------------------------------------------------
output "eks_cluster_sg_id" {
  value = data.terraform_remote_state.eks.outputs.cluster_security_group_id
}


# --------------------------------------------------------------------
# Output the BASTION security group id
# --------------------------------------------------------------------
output "bastion_sg_id" {
  value = data.terraform_remote_state.bastion.outputs.bastion_sg_id
}

# --------------------------------------------------------------------
# Output the SECRETS-MANAGER secret name
# --------------------------------------------------------------------
output "secret_name" {
  value = data.terraform_remote_state.secrets-manager.outputs.db_secret_name
}
