module "project3-alb" {
    source = "../modules/alb"
    
name = var.name
internal = var.internal
load_balancer_type = load_balancer_type
security_group = security_groups
subnets = var.subnets
vpc_tag_environment = var.vpc_tag_environment

}