locals {
   eks_cluster_name = 

  node_auto_scaler_tags {
    "k8s.io/cluster-autoscaler/enabled"               = "true"
    "k8s.io/cluster-autoscaler/${local.cluster_name}" = "owned"
  }
}
