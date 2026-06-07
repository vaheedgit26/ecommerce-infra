resource "aws_iam_policy" "product_dynamodb_policy"" {
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

resource "aws_iam_role_policy_attachment" "product_policy_attachment" {
  role       = aws_iam_role.product_role.name
  policy_arn = aws_iam_policy.product_dynamodb_policy.arn
}
