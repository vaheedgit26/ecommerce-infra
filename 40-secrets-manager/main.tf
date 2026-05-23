module "secrets_manager" {
  source = "../../../modules/secrets-manager"

  project     = var.project          # "pharma"
  env         = var.env              # "dev"

  db_username = "pharmaadmin"
  db_password = var.db_password
}
