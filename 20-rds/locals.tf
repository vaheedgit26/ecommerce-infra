locals {
  identifier ="${var.project}-${var.env}-postgre"
  db_subnet_group_name = "${var.project}-${var.env}-postgre-rds-db-subnet-group"
  ecommerce_secret_json = jsondecode(data.aws_secretsmanager_secret_version.retailstore_secret_value.secret_string)
}

locals {
  resource_name = "${var.project}/${var.env}"
  identifier ="${var.resource_name}-postgre"
  db_subnet_group_name = "${var.resource_name}-postgre-rds-db-subnet-group"
  ecommerce_secret_json = jsondecode(data.aws_secretsmanager_secret_version.retailstore_secret_value.secret_string)
}
