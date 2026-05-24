resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "9.3.1"
  namespace        = "argocd"
  create_namespace = true
  #   timeout          = 2000
  cleanup_on_fail = true
  recreate_pods   = true
  replace         = true

  set {
    name  = "server.service.type"
    value = "ClusterIP"                # LoadBalancer # ClusterIP # NodePort
  }

  set {
    name  = "server.ingress.enabled"
    value = "false"
  }

  set {
    name  = "server.extraArgs[0]"
    value = "--insecure"
  }

  set {
    name  = "crds.keep"
    value = "false"
  }

}

data "kubernetes_service_v1" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = "argocd"
  }
}
