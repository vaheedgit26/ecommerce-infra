locals {
  common_tags = {
    Project     = var.project
    Environment = var.env
    Terraform   = "true"
  }

  # eks cluster = ecommerce-dev-eks-cluster

  vpc_eks_tags = {
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/${var.project-var.env}-eks-cluster" = "owned"
  }
}
