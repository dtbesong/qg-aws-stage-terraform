Modules "project2-EC2" {
    source = "../Modules/EC2"
    instance_tenancy = var.p2_instance_tenancy
    ami_id = var.p2_ami_id
    instance_type = var.p2_instance_type
    ssh_private_key = var.p2_ssh_private_key
    instance_name_bata = var.p2_instance_name_bata
    instance_name_ovpna = var.p2_instance_name_ovpna
    instance_name_bastiona = var.p2_instance_name_bastiona






    }