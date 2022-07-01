###################################################
######### Outputs used for other TF Code ##########
###################################################

###################################################
######### Outputs for Subnet ids ##################
###################################################
output "id" {
  value = aws_vpc.main.id
}

output "pub_subnet_1a_id" {
  value = aws_subnet.public_1a.id
}

output "pub_subnet_1b_id" {
  value = aws_subnet.public_1b.id
}

output "priv_subnet_1a_id" {
  value = aws_subnet.private_1a.id
}

output "priv_subnet_1b_id" {
  value = aws_subnet.private_1b.id
}

output "priv_db_subnet_1a_id" {
  value = aws_subnet.private_db_1a.id
}

output "priv_db_subnet_1b_id" {
  value = aws_subnet.private_db_1b.id
}


##########################################
###### Outputs of Security Group ids #####
##########################################

output "rds_security_group_id" {
  value = aws_security_group.rds.id
  
}

output "app_security_group_id" {
  value = aws_security_group.app.id
  
}

output "openvpn_security_group_id" {
  value = aws_security_group.openvpn.id
  
}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
  
}

output "bastion_security_group_id" {
  value = aws_security_group.bastion.id
  
}