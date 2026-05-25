# HELM Provider
provider "helm" {
  kubernetes = {
    host                   = local.eks_host
    cluster_ca_certificate = base64decode(local.eks_cluster_ca_certificate)
    token                  = local.eks_token 
  }
}
