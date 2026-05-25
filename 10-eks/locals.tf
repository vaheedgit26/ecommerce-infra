locals {
   eks_cluster_name = data.terraform_remote_state.vpc.outputs.eks_cluster_name  
   eks_cluster_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids

  node_auto_scaler_tags = {
    "k8s.io/cluster-autoscaler/enabled"                   = "true"
    "k8s.io/cluster-autoscaler/${local.eks_cluster_name}" = "owned"
  }
}
