Modules "project3-ALB" {
    source = "../Modules/ALB"
    
name = var.p3_name
internal = var.p3_internal
load_balancer_type = p3_load_balancer_type
security_group = p3_security_groups
subnets = var.p3_subnets

}