locals {
  eks_cluster_name = "${var.project}-${var.env}-eks-cluster"   # ecommerce-dev-eks-cluster

  common_tags = {
    Project     = var.project
    Environment = var.env
    Terraform   = "True"
  }

  eks_vpc_public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "owned"          # "shared"
  }

  eks_vpc_private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "owned"           # "shared"
  }
}
