####################################################
# Target Group Creation
####################################################

resource "aws_lb_target_group" "dev_bat" {
  name        = "dev-bat"
  port        = 443
  target_type = "instance"
  protocol    = "HTTPS"
  vpc_id      =  aws_vpc.main.id                                    #module.vpc.vpc_main_id
}

####################################################
# Target Group Attachment with Instance
####################################################

resource "aws_alb_target_group_attachment" "dev_bat" {
  target_group_arn = aws_lb_target_group.dev_bat.arn
  target_id        = aws_instance.bata.id
}

####################################################
# Application Load balancer
####################################################

resource "aws_lb" "dev" {
  name               = var.name            
  internal           = var.internal
  load_balancer_type = var.load_balancer_type                   
  security_groups    = [var.security_groups]                                           
  subnets            = [var.subnets]
  

  
  enable_deletion_protection = true

  access_logs {
    bucket  = aws_s3_bucket.elb_logs.bucket
    prefix  = ""
    enabled = true
  }

  tags = {
    Name = "${var.vpc_tag_environment}-alb"
    Environment = "${var.vpc_tag_environment}"
    Type = "Network"
    Purpose = "Load Balancer"
  }
}

####################################################
# HTTP Listener
####################################################

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.dev.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

####################################################
# HTTPS Listener
####################################################

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.dev.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = "arn:aws:acm:us-east-1:483935165063:certificate/e34946ef-bdef-46e6-b525-66dbc0826106"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev_bat.arn
  }
}

####################################################
# HTTPS Listener Rules
####################################################

resource "aws_lb_listener_rule" "static" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev_bat.arn

  }

  condition {
    host_header {
      values = ["developmen*.qiigo.com"]
    }
  }
}

####################################################
# Certificate Assignment
####################################################

resource "aws_lb_listener_certificate" "dev_bat" {
  listener_arn    = aws_lb_listener.https.arn
  certificate_arn = "arn:aws:acm:us-east-1:483935165063:certificate/547ebe43-9bf7-429d-acd3-889c716136b5"
}