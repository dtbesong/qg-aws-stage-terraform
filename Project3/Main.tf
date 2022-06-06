module "project3-rds" {
    source = "../modules/rds"
    
vpc_tag_environment = var.vpc_tag_environment

vpc_tag_type = var.vpc_tag_type

}