locals {
   eks_cluster_name = data.terraform_remote_state.vpc.outputs.eks_cluster_name  
   eks_cluster_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids
   eks_node_subnet_ids    = data.terraform_remote_state.vpc.outputs.private_subnet_ids

   bastion_sg_id = data.terraform_remote_state.bastion.outputs.bastion_sg_id

  node_auto_scaler_tags = {
    "k8s.io/cluster-autoscaler/enabled"                   = "true"
    "k8s.io/cluster-autoscaler/${local.eks_cluster_name}" = "owned"
  }
}
