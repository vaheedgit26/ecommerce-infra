# Datasource: EKS Cluster Auth 
data "aws_eks_cluster_auth" "cluster" {
  name = local.eks_cluster_name
}

# HELM Provider
provider "helm" {
  kubernetes = {
    host                   = local.eks_host
    cluster_ca_certificate = base64decode(local.eks_cluster_ca_certificate)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# Terraform Kubernetes Provider
provider "kubernetes" {
  host                   = local.eks_host 
  cluster_ca_certificate = base64decode(local.eks_cluster_ca_certificate)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
