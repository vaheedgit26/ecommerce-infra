# https://docs.aws.amazon.com/eks/latest/userguide/lbc-helm.html

data "aws_iam_policy_document" "alb_controller_trust_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      identifiers = [var.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "alb_controller_role" {
  name               = "${var.project}-${var.env}-alb-controller-role"
  assume_role_policy = data.aws_iam_policy_document.alb_controller_trust_policy.json

  tags = {
    Name    = "${var.project}-${var.env}-alb-controller-role"
    Env     = var.env
    Project = var.project
  }
}
