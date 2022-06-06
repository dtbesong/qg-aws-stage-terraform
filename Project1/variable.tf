variable "p1_vpc_cidr_block" {
  default = ""
}

variable "subnet_pub_1a_cidr_block" {
  default = ""
}

variable "subnet_priv_1a_cidr_block" {
  default = ""
}

variable "subnet_priv_db_1a_cidr_block" {
  default = ""
}

variable "subnet_pub_1b_cidr_block" {
  default = ""
}

variable "subnet_priv_1b_cidr_block" {
  default = ""
}

variable "subnet_priv_db_1b_cidr_block" {
  default = ""
}










variable "vpc_tag_name" {
  default = ""
}

variable "vpc_tag_environment" {
  default = ""
}

variable "vpc_tag_type" {
  default = ""
}

variable "vpc_tag_purpose" {
  default = ""
}








variable "subnet_1a_az" {
  default = ""
}

variable "subnet_1b_az" {
  default = ""
}

variable "aws_region" {
  description = "AWS region for all resources."

  type    = string
  default = "us-east-1"
}







variable "region" {
  description = "The AWS Region to use"
  type = string  
  default = ""
}

# variable "profileapplication" {
#     default = ""
  
# }

# variable "profiletest/sta" {
#   default =  ""
  
# }





locals {
  aws_s3_bucket = "qg-${var.vpc_tag_environment}-cloudtrail-allmanagement-s3ue1"
}


