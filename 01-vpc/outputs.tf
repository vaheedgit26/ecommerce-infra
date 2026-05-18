output "project"                 { value = module.vpc.project }
output "env"                     { value = module.vpc.env     }

output "vpc_id"                  { value = module.vpc.vpc.id   }
output "vpc_cidr"                { value = module.vpc.vpc_cidr }
output "availability_zones"      { value = module.vpc.azs      }

output "public_subnet_cidr"      { value = module.vpc.public_subnet_cidr   }
output "private_subnet_cidr"     { value = module.vpc.private_subnet_cidr  }
output "database_subnet_cidr"    { value = module.vpc.database_subnet_cidr }

output "public_subnet_ids"       { value = module.vpc.public[*].id  }
output "private_subnet_ids"      { value = module.vpc.private.*.id  }
output "database_subnet_ids"     { value = module.vpc.database.*.id }

output "public_route_table_id"   { value = module.vpc.public.id   }
output "private_route_table_id"  { value = module.vpc.private.id  }
output "database_route_table_id" { value = module.vpc.database.id }

# This returns entire 'internet_gateway' object, if you want only 'id' then use "aws_internet_gateway.internet_gateway.id"
output "internet_gateway"        { value = module.vpc.internet_gateway }
