resource "aws_iam_policy" "eso_secrets_policy" {
  name        = "${local.resource_name}-eso-secrets-policy"
  description = "Allow External Secrets Operator to read /${var.project}/${var.env} secrets from AWS Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      # 🔐 Secrets Manager access 
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "arn:aws:secretsmanager:*:${local.aws_account_id}:secret:/${var.project}/${var.env}/*"
      },

      # 🔐 SSM Parameter Store access
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = "arn:aws:ssm:*:${local.aws_account_id}:parameter/${var.project}/${var.env}/*"
        # Resource = "arn:aws:ssm:${var.region}:${local.aws_account_id}:parameter/${var.project}/${var.env}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eso_secrets_policy_attachment" {
  role       = aws_iam_role.eso_role.name
  policy_arn = aws_iam_policy.eso_secrets_policy.arn
}
