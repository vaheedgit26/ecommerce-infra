module "rds" {
  source = "git::https://github.com/vaheedgit26/Infra-1.0.git//modules/rds"
  database_subnet_ids = data.terraform_remote_state.vpc.outputs.database_subnet_ids       # For subnet group creation

  identifier              = local.identifier
  availability_zone       = local.availability_zone        # var.availability_zone
  engine                  = "postgres"
  engine_version          = "15.7"
  instance_class          = "db.t3.micro"
  allocated_storage       = 10  # 20
  storage_type            = "gp2"
  storage_encrypted       = false   # true
  db_name                 = "ecommercedb"
  username                = local.ecommerce_secret_json.username
  password                = local.ecommerce_secret_json.password
  db_subnet_group_name    = local.db_subnet_group_name
  vpc_security_group_ids  = local.vpc_security_group_ids

  common_tags = local.common_tags
}
