locals {
  resource_name = "${var.project}/${var.env}"
 
  availability_zone      = data.terraform_remote_state.vpc.outputs.availability_zones[0]
  sg_name                = "${local.resource_name}-postgre-rds-sg"
  identifier             = "${local.resource_name}-postgre"
  db_subnet_group_name   = "${local.resource_name}-postgre-rds-db-subnet-group"
  ecommerce_secret_json  = jsondecode(data.aws_secretsmanager_secret_version.ecommerce_secret_value.secret_string)
  vpc_security_group_ids = [data.terraform_remote_state.eks.outputs.cluster_security_group_id, data.terraform_remote_state.bastion.outputs.bastion_sg_id]

  common_tags = {
    Project     = var.project
    Environment = var.env
    Terraform   = "True"
  }

}
