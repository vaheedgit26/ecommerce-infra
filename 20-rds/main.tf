module "rds" {
  source = "git::https://github.com/vaheedgit26/Infra-1.0.git//modules/rds"
  database_subnet_ids = data.terraform_remote_state.vpc.outputs.database_subnet_ids       # For subnet group creation

  identifier              = "${var.project}-${var.env}-postgre"
  availability_zone       = data.terraform_remote_state.vpc.outputs.availability_zones[0]         # var.availability_zone
  engine                  = "postgres"
  engine_version          = "15.7"
  instance_class          = "db.t3.micro"
  allocated_storage       = 10  # 20
  storage_type            = "gp2"
  storage_encrypted       = false   # true
  db_name                 = "ecommercedb"
  username                = local.ecommerce_secret_json.db_username
  password                = local.ecommerce_secret_json.db_password
  db_subnet_group_name    = "${var.project}-${var.env}-postgre-rds-db-subnet-group" 
  vpc_security_group_ids  = [data.terraform_remote_state.eks.outputs.cluster_security_group_id, data.terraform_remote_state.bastion.outputs.bastion_sg_id]            
}
