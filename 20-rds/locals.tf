locals {
  ecommerce_secret_json = jsondecode(data.aws_secretsmanager_secret_version.retailstore_secret_value.secret_string)
}
