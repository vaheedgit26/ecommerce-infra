resource "aws_iam_policy" "eso_secrets_policy" {
  name        = "${local.resource_name}-eso-secrets-policy"
  description = "Allow External Secrets Operator to read /${var.project}/${var.env} secrets from AWS Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "arn:aws:secretsmanager:*:${var.aws_account_id}:secret:/${var.project}/${var.env}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eso_secrets_attachment" {
  role       = aws_iam_role.eso_role.name
  policy_arn = aws_iam_policy.eso_secrets_policy.arn
}
