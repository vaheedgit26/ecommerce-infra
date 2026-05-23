locals {

  s3_bucket_name = "tfstate-${var.project}-${var.env}-${var.region}"

  common_tags = {
    Project     = var.project
    Environment = var.env
    Terraform   = "True"
  }

}
