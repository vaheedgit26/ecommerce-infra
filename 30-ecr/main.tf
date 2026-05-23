module "ecr" {
  source = "git::https://github.com/vaheedgit26/Infra-1.0.git//modules/ecr"

  project = var.project  # "ecommerce"
  env     = var.env      # "dev"
  repositories = [
    "api-gateway",
    "auth-service",
    "pharma-ui",
    "notification-service",
    "catalog-service"
  ]
}
