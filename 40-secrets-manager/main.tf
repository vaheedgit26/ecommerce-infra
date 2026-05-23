module "secrets_manager" {
  source = "git::https://github.com/vaheedgit26/Infra-1.0.git//modules/secrets-manager"

  project     = var.project          # "ecommerce"
  env         = var.env              # "dev"

  db_username = "ecommerceadmin"
  db_password = var.db_password
}
