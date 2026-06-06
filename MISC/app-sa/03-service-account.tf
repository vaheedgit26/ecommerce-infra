resource "kubernetes_service_account" "app_sa" {
  metadata {
    name      = "${var.service_account_name}"
    namespace = var.namespace

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.app_irsa_role.arn
    }
  }
}
