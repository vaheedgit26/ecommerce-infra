module "secrets_manager" {
  source = "git::https://github.com/vaheedgit26/Infra-1.0.git//modules/secrets-manager"

  project     = var.project          # "ecommerce"
  env         = var.env              # "dev"
  secret_name = var.secret_name      # /ecommerce/dev/db-credentials
  db_username = var.db_username
  db_password = var.db_password
}
