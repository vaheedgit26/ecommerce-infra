# Calling EKS Cluster
module "eks" {
  source = "git::https://github.com/vaheedgit26/infra-1.0.git//modules/eks"

  project             = var.project  # "ecommerce"
  env                 = var.env      # "dev"

  # public_subnet_ids   = module.vpc.public_subnet_ids      # For Tagging 
  # private_subnet_ids  = module.vpc.private_subnet_ids     # For Tagging 

  cluster_name                     = local.eks_cluster_name
  cluster_version                  = "1.33"
  cluster_subnet_ids               = local.eks_cluster_subnet_ids       # (since vpc outputs as list, so [] not required)
  cluster_endpoint_public_access   = false                              # Control plane public access
  cluster_endpoint_private_access  = true                               # Control plane to Node and vice versa communication
  # cluster_addl_security_group_ids  = [module.vpc.bastion_host_sg_id]  # This is additional cluster SG and the default cluster SG is intact

  node_subnet_ids       = local.eks_node_subnet_ids
  node_instance_types   = ["t3.small"]
  node_capacity_type    = "SPOT"        # ON_DEMAND/ SPOT
  node_auto_scaler_tags = local.node_auto_scaler_tags

  # Cluster access from Bastion
  enable_bastion_access = true
  bastion_sg_id         = local.bastion_sg_id

  # node_ssh_public_key = "us-east-1"
  # node_addl_sg_ids    = [module.bastion_sg.sg_id]               # SSH to Node instance, This is additional cluster SG and the default cluster SG is intact
  
  desired_capacity    = 2
  min_size            = 2
  max_size            = 4
}
