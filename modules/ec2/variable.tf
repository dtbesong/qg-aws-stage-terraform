variable "instance_tenancy" {
    description = "Defines the tenancy of the VPC (Default or Dedicated)"
    type        = string
  
}

variable "ami_id" {
    description = "AMI ID for the latest version of Amazon Linux 2"
    type        = string

}



variable "instance_type" {
    description = "Instance type to create an instance"
    type        = string

}


variable "instance_type_ovpna" {
    description = "Instance type to create an instance"
    type        = string

}



variable "instance_type_bastia" {
    description = "Instance type to create an instance"
    type        = string

}

variable "ssh_private_key" {
    description = "Pem file of Keypair for ec2-user in the instance"
    type        = string

}

variable "instance_name_bata" {
    description = "Name of the instance"
    type = string

}

variable "instance_name_ovpna" {
    description = "Name of the instance"
    type = string
 
}

variable "instance_name_bastiona" {
    description = "Name of the instance"
    type = string
 
}

variable "vpc_tag_environment" {
    description = "environment name of the vpc"
    type = string


}

