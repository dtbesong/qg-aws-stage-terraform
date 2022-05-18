###################################################
######### Outputs used for other TF Code ##########
###################################################
output "vpc_main_id" {
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