output "bastion_public_ip" {
  value = module.bastion_ec2.network.public_ip
}

output "bastion_sg_id" {
  value = module.bastion_sg.sg_id
}
