data "aws_iam_policy_document" "app_pod_trust_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      # variable = trim(replace(local.eks_oidc_provider_url, "https://", ""), "/")  # Ensures no trailing slash
      variable = "${replace(local.eks_oidc_provider_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.namespace}:${var.service_account_name}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(local.eks_oidc_provider_url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      identifiers = [local.eks_oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "eso_role" {
  name               = "${local.resource_name}-app-pod-role"
  assume_role_policy = data.aws_iam_policy_document.eso_trust_policy.json

  tags = {
    Name    = "${local.resource_name}-app-pod-role"
    Env     = var.env
    Project = var.project
  }
}
