# S3-MODULE Calling
module "s3" {
  source = "git::https://github.com/vaheedgit26/Infra-1.0.git//modules/s3"      # Give the path to S3 MODULE accordingly

  s3_bucket_name = local.s3_bucket_name 
  project        = var.project
  env            = var.env
  region         = var.region

  common_tags    = local.common_tags
}
