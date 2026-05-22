module "rds" {
  source = "git::https://github.com/vaheedgit26/Infra-1.0.git//modules/rds"
  database_subnet_ids = local.database_subnet_ids       # For subnet group creation

  identifier              = "${var.project}-${var.env}-postgres"
  availability_zone       = var.availability_zone
  engine                  = "postgres"
  engine_version          = "15.7"
  instance_class          = "db.t3.micro"
  allocated_storage       = 10  # 20
  storage_type            = "gp2"
  storage_encrypted       = false   # true
  db_name                 = ""
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.database_subnet_group.name  # var.db_subnet_group_name
  vpc_security_group_ids  = var.vpc_security_group_ids
}
