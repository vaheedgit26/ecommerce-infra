locals {
  resource_name = "${var.project}/${var.env}"

  identifier            = "${local.resource_name}-postgre"
  db_subnet_group_name  = "${local.resource_name}-postgre-rds-db-subnet-group"
  ecommerce_secret_json = jsondecode(data.aws_secretsmanager_secret_version.retailstore_secret_value.secret_string)

  common_tags = {
    Project     = var.project
    Environment = var.env
    Terraform   = "True"
  }

}
