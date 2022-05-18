Modules "project1-vpc" {
    source = "../Modules/vpc"
    
    }


output "vpc_main_id" {
  value = module.project1-vpc.main
}


output "pub_subnet_1a_id" {
  value = module.project1-vpc.public_1a
}

output "pub_subnet_1b_id" {
  value = module.project1-vpc.public_1b
}

output "priv_subnet_1a_id" {
  value = module.project1-vpc.private_1a
}

output "priv_subnet_1b_id" {
  value = module.project1-vpc.private_1b
}

output "priv_db_subnet_1a_id" {
  value = module.project1-vpc.private_db_1a
}

output "priv_db_subnet_1b_id" {
  value = module.project1-vpc.private_db_1b
}