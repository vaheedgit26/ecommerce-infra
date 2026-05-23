locals {

  sg_name = "${var.project}-${var.env}-bastion-sg"

  common_tags = {
    Project     = var.project
    Environment = var.env
    Terraform   = "True"
  }

}
