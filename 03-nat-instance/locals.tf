locals {
  
  common_tags = {
    Project     = var.project
    Environment = var.env
    Terraform   = "True"
  }

}
