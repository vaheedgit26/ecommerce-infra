# --------------------------------------------------------------------
# Reference the Remote State from VPC Project
# --------------------------------------------------------------------
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = var.remote_state_s3_bucket                                   # Name of the remote S3 bucket where the VPC state is stored
    key    = "${var.project}/${var.env}/vpc/terraform.tfstate"            # Path to the VPC tfstate file within the bucket
    region = var.region                                                   # Region where the S3 bucket and DynamoDB table exist
  }
}

# --------------------------------------------------------------------
# Reference the Remote State from BASTION Project
# --------------------------------------------------------------------
data "terraform_remote_state" "bastion" {
  backend = "s3"

  config = {
    bucket = var.remote_state_s3_bucket                                   # Name of the remote S3 bucket where the VPC state is stored
    key    = "${var.project}/${var.env}/bastion/terraform.tfstate"        # Path to the BASTION tfstate file within the bucket
    region = var.region                                                   # Region where the S3 bucket and DynamoDB table exist
  }
}

# --------------------------------------------------------------------
# Output the VPC ID from the remote VPC state
# --------------------------------------------------------------------
output "vpc_id" {
  value = data.terraform_remote_state.vpc.outputs.vpc_id
}

# --------------------------------------------------------------------
# Output the list of private subnets from the VPC
# --------------------------------------------------------------------
output "private_subnet_ids" {
  value = data.terraform_remote_state.vpc.outputs.private_subnet_ids
}


# --------------------------------------------------------------------
# Output the list of public subnets from the VPC
# --------------------------------------------------------------------
output "public_subnet_ids" {
  value = data.terraform_remote_state.vpc.outputs.public_subnet_ids
}

# --------------------------------------------------------------------
# Output the BASTION SG from the remote BASTION state
# --------------------------------------------------------------------
output "bastion_sg_id" {
  value = data.terraform_remote_state.bastion.outputs.bastion_sg_id
}
