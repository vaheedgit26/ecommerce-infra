# HELM Provider
provider "helm" {
  kubernetes = {
    host                   = local.eks_host
    cluster_ca_certificate = base64decode(local.eks_cluster_ca_certificate)
    token                  = local.eks_token  # data.aws_eks_cluster_auth.cluster.token
  }
}

# Terraform Kubernetes Provider
provider "kubernetes" {
  host                   = local.eks_host 
  cluster_ca_certificate = base64decode(local.eks_cluster_ca_certificate)
  token                  = local.eks_token    # data.aws_eks_cluster_auth.cluster.token
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "9.3.1"
  namespace        = "argocd"
  create_namespace = true
  
  wait            = true         # Wait for resources to become Ready
  timeout         = 600
  cleanup_on_fail = true 

  # recreate_pods   = true
  # replace         = true
  # force_update    = true

  set = [
    {
      name  = "server.service.type"
      value = "ClusterIP"                # LoadBalancer # ClusterIP # NodePort
    },

    {
      name  = "server.extraArgs[0]"
      value = "--insecure"
    },

    {
      name  = "rbac.create"
      value = "true"
    },

    {
      name  = "installCRDs"
      value = "true"
    },

    {
      name  = "crds.keep"
      value = "false"
    }
  ]
}

data "kubernetes_service_v1" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = "argocd"
  }
  depends_on = [helm_release.argocd]
}

output "service_type" {
  value = data.kubernetes_service_v1.argocd_server.spec[0].type
}
