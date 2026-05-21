output "bastion_public_ip" {
  value = module.bastion_ec2.network.public_ip
}

output "bastion_security_group_ids" {
  value = module.bastion_ec2.security_group_ids
}
