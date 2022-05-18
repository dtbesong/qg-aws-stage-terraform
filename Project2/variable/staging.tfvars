#####################################################
# EC2 Requirement
#####################################################

variable "instance_tenancy" {
  description = "Defines the tenancy of the VPC (Default or Dedicated)"
  type        = string
  default     = "default"
}

p2_ami_id = "ami-08e4e35cccc6189f4"
}

variable "instance_type" {
  description = "Instance type to create an instance"
  type        = string
  default     = "m5a.large"
}

variable "ssh_private_key" {
  description = "Pem file of Keypair for ec2-user in the instance"
  type        = string
  default     = "./$[var.instance_name].pem"
}

variable "instance_name_bata" {
  description = "Name of the instance"
  type = string
  default = "qgdevbata001"
}

variable "instance_name_ovpna" {
  description = "Name of the instance"
  type = string
  default = "qgdevovpna001"
}

variable "instance_name_bastiona" {
  description = "Name of the instance"
  type = string
  default = "qgdevbastia001"
}

