name               = "dev-alb"
internal           = false
load_balancer_type = "application"
security_groups    = [aws_security_group.alb.id]
subnets            = [              ]                  

