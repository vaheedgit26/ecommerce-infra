#-------------------------------------------
# COGNITO USER POOL
#-------------------------------------------
resource "aws_cognito_user_pool" "pool" {
  name = "${var.project}-${var.env}-pool"

  password_policy {
    minimum_length    = 8
    require_uppercase = true
    require_lowercase = true
    require_numbers   = true
  }
}

#-------------------------------------------
# USER POOL CLIENT (for frontend login)
#-------------------------------------------
resource "aws_cognito_user_pool_client" "client" {
  name         = "${var.project}-${var.env}-client"
  user_pool_id = aws_cognito_user_pool.pool.id

  generate_secret = false

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
}
