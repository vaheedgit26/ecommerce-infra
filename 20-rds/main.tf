module "rds" {
  source = "git::https://github.com/vaheedgit26/Infra-1.0.git//modules/rds"
  database_subnet_ids = data.terraform_remote_state.vpc.outputs.database_subnet_ids       # For subnet group creation

  identifier              = "${var.project}-${var.env}-postgres"
  availability_zone       = data.terraform_remote_state.vpc.outputs.availability_zones[0]         # var.availability_zone
  engine                  = "postgres"
  engine_version          = "15.7"
  instance_class          = "db.t3.micro"
  allocated_storage       = 10  # 20
  storage_type            = "gp2"
  storage_encrypted       = false   # true
  db_name                 = ""
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = "${var.project}-${var.env}-rds-subnet-group"  # var.db_subnet_group_name
  vpc_security_group_ids  = module.rds_postgre_sg.sg_id                   # [module.eks.cluster_security_group_id, module.bastion_sg.sg_id]    # var.vpc_security_group_ids
}
