



module "ec2" {
    source = "../modules/ec2"
    instance_tenancy = var.instance_tenancy
    ami_id = var.ami_id
    instance_type = var.instance_type
    # instance_type_ovpna = var.instance_type_ovpna
    # instance_type_bastia = var.instance_type_bastia
    ssh_private_key = var.ssh_private_key
    instance_name_bata = var.instance_name_bata
    # instance_name_ovpna = var.instance_name_ovpna
    # instance_name_bastiona = var.instance_name_bastiona
    vpc_tag_environment = var.vpc_tag_environment
    

  
    }






