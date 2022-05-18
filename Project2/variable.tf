variable "p2_instance_tenancy" {
  description = "Defines the tenancy of the VPC (Default or Dedicated)"
  type        = string
  default     = ""
}

variable "p2_ami_id" {
  description = "AMI ID for the latest version of Amazon Linux 2"
  type        = string
  default     = ""
}

variable "p2_instance_type" {
  description = "Instance type to create an instance"
  type        = string
  default     = ""
}

variable "p2_ssh_private_key" {
  description = "Pem file of Keypair for ec2-user in the instance"
  type        = string
  default     = ""
}

variable "p2_instance_name_bata" {
  description = "Name of the instance"
  type = string
  default = ""
}

variable "p2_instance_name_ovpna" {
  description = "Name of the instance"
  type = string
  default = ""
}

variable "p2_instance_name_bastiona" {
  description = "Name of the instance"
  type = string
  default = ""
}

