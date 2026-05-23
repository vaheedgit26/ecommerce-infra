module "secrets_manager" {
  source = "git::https://github.com/vaheedgit26/Infra-1.0.git//modules/secrets-manager"

  project     = var.project          # "pharma"
  env         = var.env              # "dev"

  db_username = "pharmaadmin"
  db_password = var.db_password
}
