# Security Group for Bastion Host
module "rds_postgre_sg" {
  source = "git::https://github.com/vaheedgit26/Infra-1.0.git//modules/sg"

  vpc_id         = data.terraform_remote_state.vpc.outputs.vpc_id
  sg_name        = "rds_sg"
  sg_description = "RDS Instance Security Group"

  project        = var.project
  env            = var.env
  common_tags    = local.common_tags
}

# bastion (public_subnet) ---> postgres (database_subnet)
resource "aws_security_group_rule" "postgre_bastion" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = module.bastion_sg.sg_id     # you need to update eks cluster security group
  security_group_id        = module.rds_postgre_sg.sg_id

  # depends_on = [module.bastion_sg]
}

# backend (private instances in private_subnet)  --->  mysql (database_subnet)
resource "aws_security_group_rule" "mysql_backend" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = module.backend_sg.sg_id   # you need to update eks cluster security group
  security_group_id        = module.rds_postgre_sg.sg_id

  # depends_on = [module.backend_sg]
}
