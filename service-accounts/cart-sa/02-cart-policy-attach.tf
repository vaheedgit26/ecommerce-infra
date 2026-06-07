resource "aws_iam_policy" "cart_dynamodb_policy"" {
  name = "${local.resource_name}-dynamodb-access"
  description = "Allow product pod to access ${var.dynamodb_table} dynamo db table"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:UpdateItem"
        ]
        Resource = "arn:aws:dynamodb:${var.region}:${local.aws_account_id}:table/${var.dynamodb_table}"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cart_policy_attachment" {
  role       = aws_iam_role.cart_role.name
  policy_arn = aws_iam_policy.cart_dynamodb_policy.arn
}
