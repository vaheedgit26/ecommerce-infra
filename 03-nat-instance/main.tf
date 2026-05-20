# NAT-INSTANCE Module Calling
module "nat_instance" {
  source = "git::https://github.com/vaheedgit26/Infra-1.0//modules/nat-instance"
  # depends_on = [module.vpc]

  vpc_id                                  = module.vpc.vpc_id
  vpc_cidr                                = module.vpc.vpc_cidr
  ami_id                                  = var.ami_id            # "ami-0ddfba243cbee3768" 
  public_key_name                         = var.public_key_name   # "us-east-1"
  instance_type                           = "t3.micro"            # var.instance_type

  public_subnet_ID_to_launch_nat_instance = module.vpc.public_subnet_ids[0]
  public_subnet_cidr                      = module.vpc.public_subnet_cidr       # for private instance sg purpose
  private_subnet_cidr                     = module.vpc.private_subnet_cidr      # for database instance sg purpose
  # private_subnet_ids                    = local.private_subnet_ids #module.vpc.private_subnet_ids 

  root_volume_size                        = 8       # ( default: 8 )
  private_route_table_id                  = module.vpc.private_route_table_id    # NAT purpose
  database_route_table_id                 = module.vpc.database_route_table_id   # NAT purpose

  remote_ip_to_connect_nat_instance       = "0.0.0.0/0"      # For nat-instance sg  # "${var.remote_ip_to_connect_nat_instance}/32"

  # is_nat_instance = true
  is_eip_required = true

  project      = var.project
  env          = var.env
  common_tags  = local.common_tags
}
