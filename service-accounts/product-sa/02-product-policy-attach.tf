resource "aws_iam_policy" "product_dynamodb_policy"" {
  name = "${var.project}-${var.env}-dynamodb-access"
  description = "Allow product pod to read /${var.project}/${var.env} dynamo db table"

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
        Resource = "arn:aws:dynamodb:${var.region}:${local.aws_account_id}:table/${var.project}-${var.env}-products"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eso_secrets_policy_attachment" {
  role       = aws_iam_role.product_role.name
  policy_arn = aws_iam_policy.product_dynamodb_policy.arn
}
