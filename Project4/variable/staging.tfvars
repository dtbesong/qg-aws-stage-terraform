name               = "staging-alb"
internal           = false
load_balancer_type = "application"
security_groups    = [aws_security_group.alb.id]
subnets            = [        
    module.vpc.public_subnet_1a,
    module.vpc.public_subnet_1b,
]   
vpc_tag_environment = "staging"               

