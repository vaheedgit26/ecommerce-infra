locals {

  common_tags = {
    Project     = var.project
    Environment = var.env
    Terraform   = "True"
  }

  db_secret_name ="/${var.project}/${var.env}/db-credentials"
}
