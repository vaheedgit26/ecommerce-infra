resource "kubernetes_service_account" "product_sa" {
  metadata {
    name      = var.service_account_name
    namespace = var.namespace

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.product_role.arn
    }
  }
}
