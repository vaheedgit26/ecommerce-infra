# Security Group for Bastion Host
module "bastion_sg" {
  source = "git::https://github.com/vaheedgit26/Infra-1.0.git//modules/sg"

  vpc_id         = data.terraform_remote_state.vpc.outputs.vpc_id
  sg_name        = local.sg_name
  sg_description = "Bastion Instance Security Group"

  common_tags    = local.common_tags
}

# Security Group Rule for Bastion Host
resource "aws_security_group_rule" "bastion_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.bastion_sg.sg_id                       # aws_security_group.sg_nat_instance.id
}

# Security Group Rule for Bastion Host (For Argocd access)
resource "aws_security_group_rule" "bastion_argocd" {
  type              = "ingress"
  from_port         = 8090
  to_port           = 8090
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.bastion_sg.sg_id                       # aws_security_group.sg_nat_instance.id
}

# Bastion Host
module "bastion_ec2" {
  source = "git::https://github.com/vaheedgit26/Infra-1.0.git//modules/ec2"

  ami_id                      = var.ami_id                        # "ami-0ea87431b78a82070"
  instance_type               = "t3.micro"                        # var.instance_type
  public_key_name             = var.public_key_name               # "us-east-1"
  sg_ids                      = [module.bastion_sg.sg_id]         # [local.sg_id]
  subnet_id                   = data.terraform_remote_state.vpc.outputs.public_subnet_ids[0]   # local.public_subnet_ids[0] 
  associate_public_ip_address = true
  what_type_instance          = "Bastion"

  # user_data = file("${path.module}/mysql_client_8.sh")
 
  project      = var.project
  env          = var.env
  common_tags  = local.common_tags
}
