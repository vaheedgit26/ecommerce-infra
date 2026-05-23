locals {

  s3_bucket_name = 
  common_tags = {
    Project     = var.project
    Environment = var.env
    Terraform   = "True"
  }

}
