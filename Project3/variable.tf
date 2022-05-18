variable "p3_name" {

  description = "name of ALB"
  type        = string
  default     = ""
   
 } 


variable "p3_internal" {

  description = "is LB internal or internet facing"
  type        = string
  default     = ""
  
}


variable "p3_load_balancer_type" {

  description = "Type of Load balancer"
  type        = string
  default     = ""
  
}

variable "p3_security_groups" {

  description = "LB security groups"
  type        = string
  default     = ""
  
}

variable "p3_subnets" {

  description = "subnets to situate LB"
  type        = string
  default     = ""
  
}
