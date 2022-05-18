variable "p1_vpc_cidrblock" {
  default = ""
}

variable "p1_subnet_pub_1a_cidr" {
  default = ""
}

variable "p1_subnet_priv_1a_cidr" {
  default = ""
}

variable "p1_subnet_priv_db_1a_cidr" {
  default = ""
}

variable "p1_subnet_pub_1b_cidr" {
  default = ""
}

variable "p1_subnet_priv_1b_cidr" {
  default = ""
}

variable "p1_subnet_priv_db_1b_cidr" {
  default = ""
}










variable "p1_vpc_tag_name" {
  default = ""
}

variable "p1_vpc_tag_environment" {
  default = ""
}

variable "p1_vpc_tag_type" {
  default = ""
}

variable "p1_vpc_tag_purpose" {
  default = ""
}








variable "p1_subnet_1a_az" {
  default = ""
}

variable "p1_subnet_1b_az" {
  default = ""
}







variable "region" {
  description = "The AWS Region to use"
  type = string  
  default = ""
}

variable "profileapplication" {
    default = ""
  
}

variable "profiletest/sta" {
  default =  ""
  
}





locals {
  aws_s3_bucket = "qg-${var.vpc_tag_environment}-cloudtrail-allmanagement-s3ue1"
}