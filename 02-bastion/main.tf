# Security Group for Bastion Host
module "bastion_sg" {
  source = "../../../modules/sg"

  project        = var.project
  env            = var.env
  vpc_id         = module.vpc.vpc_id
  sg_name        = "bastion_sg"
  sg_description = "Bastion Instance Security Group"
  common_tags    = local.common_tags
}

# Security Group Rule for Bastion Host
resource "aws_security_group_rule" "bastion_internet" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.bastion_sg.sg_id                       # aws_security_group.sg_nat_instance.id
}

# Bastion Host
module "bastion_ec2" {
  source = "../../../modules/ec2"

  ami_id                      = var.ami_id
  instance_type               = "t3.micro"                        # var.instance_type
  public_key_name             = var.public_key_name
  sg_ids                      = [module.bastion_sg.sg_id]           # [local.sg_id]
  subnet_id                   = module.vpc.public_subnet_ids[0]   # local.public_subnet_ids[0] # "subnet-088e8443a70102e2a" #1a
  associate_public_ip_address = true
  what_type_instance          = "bastion"

  # user_data = file("${path.module}/mysql_client_8.sh")
  # is_nat_instance             = var.is_nat_instance  # creates NAT instance if true

  project      = var.project
  env          = var.env
  common_tags  = local.common_tags
}
