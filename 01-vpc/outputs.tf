output "project"                 { value = module.vpc.project }
output "env"                     { value = module.vpc.env     }

output "vpc_id"                  { value = module.vpc.vpc_id   }
output "vpc_cidr"                { value = module.vpc.vpc_cidr }
output "availability_zones"      { value = module.vpc.availability_zones }

output "public_subnet_cidr"      { value = module.vpc.public_subnet_cidr   }
output "private_subnet_cidr"     { value = module.vpc.private_subnet_cidr  }
output "database_subnet_cidr"    { value = module.vpc.database_subnet_cidr }

output "public_subnet_ids"       { value = module.vpc.public_subnet_ids   }
output "private_subnet_ids"      { value = module.vpc.private_subnet_ids  }
output "database_subnet_ids"     { value = module.vpc.database_subnet_ids }

output "public_route_table_id"   { value = module.vpc.public_route_table_id   }
output "private_route_table_id"  { value = module.vpc.private_route_table_id  }
output "database_route_table_id" { value = module.vpc.database_route_table_id }

# This returns entire 'internet_gateway' object, if you want only 'id' then use "aws_internet_gateway.internet_gateway.id"
output "internet_gateway"        { value = module.vpc.internet_gateway }

output "eks_cluster_name"        { value = module.vpc.eks_cluster_name }
