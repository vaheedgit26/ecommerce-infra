locals {

  common_tags = {
    Project     = var.project
    Environment = var.env
    Terraform   = "True"
  }

  postgre_db_secret_name ="/${var.project}/${var.env}/postgre-db-credentials"
}
