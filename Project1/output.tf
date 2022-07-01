output "id" {
  value = module.vpc.id
}


output "pub_subnet_1a_id" {
  value = module.vpc.pub_subnet_1a_id
}

output "pub_subnet_1b_id" {
  value = module.vpc.pub_subnet_1b_id
}

output "priv_subnet_1a_id" {
  value = module.vpc.priv_subnet_1a_id
}

output "priv_subnet_1b_id" {
  value = module.vpc.priv_subnet_1b_id
}

output "priv_db_subnet_1a_id" {
  value = module.vpc.priv_db_subnet_1a_id
}

output "priv_db_subnet_1b_id" {
  value = module.vpc.priv_db_subnet_1b_id
}





output "rds_security_group_id" {
  value = module.vpc.rds_security_group_id
  
}

output "app_security_group_id" {
  value = module.vpc.app_security_group_id
  
}

output "openvpn_security_group_id" {
  value = module.vpc.openvpn_security_group_id
  
}

output "alb_security_group_id" {
  value = module.vpc.alb_security_group_id
  
}

output "bastion_security_group_id" {
  value = module.vpc.bastion_security_group_id
  
}