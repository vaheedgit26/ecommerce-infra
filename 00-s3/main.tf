# S3-MODULE Calling
module "s3" {
  source = "../../../modules/s3"      # Give the path to S3 MODULE accordingly

  s3_bucket_name = "tfstate-${var.project}-${var.env}-${var.region}"
  project        = var.project
  env            = var.env
  region         = var.region
}
