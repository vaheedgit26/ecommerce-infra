# Use existing AWS Secrets Manager Secret (which is already created)
data "aws_secretsmanager_secret" "ecommerce_secret" {
  name = var.aws_secret_name
}

data "aws_secretsmanager_secret_version" "ecommerce_secret_value" {
  secret_id = data.aws_secretsmanager_secret.ecommerce_secret.id
}
