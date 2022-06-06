variable "name" {

  description = "name of ALB"
  type        = string
  default     = ""
   
 } 


variable "internal" {

  description = "is LB internal or internet facing"
  type        = string
  default     = ""
  
}


variable "load_balancer_type" {

  description = "Type of Load balancer"
  type        = string
  default     = ""
  
}

variable "security_groups" {

  description = "LB security groups"
  type        = string
  default     = ""
  
}

variable "subnets" {

  description = "subnets to situate LB"
  type        = string
  default     = ""
  
}

variable "vpc_tag_environment" {
  description = "vpc environment"
  type        = string
  default = ""
}
