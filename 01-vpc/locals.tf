locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.env
    Terraform   = "true"
  }

  vpc_eks_tags = {
    "kubernetes.io/role/elb" = "1"
     "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
  }
}
