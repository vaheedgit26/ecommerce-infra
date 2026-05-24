# ArgoCD IRSA Role ( Trust Policy )
data "aws_iam_policy_document" "argocd_trust_policy" {      
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(local.eks_oidc_provider_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:argocd:argocd-application-controller"]
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

resource "aws_iam_role" "argocd_role" {
  name               = "${local.resource_name}-argocd-role"
  assume_role_policy = data.aws_iam_policy_document.argocd_trust_policy.json

  tags = {
    Name    = "${local.resource_name}-argocd-role"
    Env     = var.env
    Project = var.project
  }
}
