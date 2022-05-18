data "aws_ami" "openvpn-ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["*fe8020db-5343-4c43-9e65-5ed4a825c931*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["679593333241"]
}

###################################################
# EIP 
###################################################

resource "aws_eip" "openvpn" {
  instance = aws_instance.ovpna.id
  vpc = true
}

####################################################################

# Creating BAT App EC2 Instance

####################################################################

resource "aws_instance" "bata" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_1a.id                 #module.vpc.priv_subnet_1a_id
  vpc_security_group_ids = [aws_security_group.app.id]
  key_name               = var.instance_name_bata                #"${var.instance_name_bata}"

  # root disk
  root_block_device {
    volume_size           = "50"
    volume_type           = "gp2"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    "Name"        = var.instance_name_beta                        #"${var.instance_name_bata}"
    "Environment" = "${var.vpc_tag_environment}"
    "map-migrated"   = "d-server-001sw2ungcy573"
  }

  timeouts {
    create = "10m"
  }

}

####################################################################

# Creating OpenVPN EC2 Instance

####################################################################

resource "aws_instance" "ovpna" {
  ami                         = data.aws_ami.openvpn-ami.id
  instance_type               = var.instance_type                 #"t3a.micro"
  subnet_id                   = aws_subnet.public_1a.id                   #module.vpc.pub_subnet_1a_id
  associate_public_ip_address = "true"
  vpc_security_group_ids      = [aws_security_group.openvpn.id]
  key_name                    = var.instance_name_ovpna           #"${var.instance_name_ovpna}"
  source_dest_check           = "false"

  # root disk
  root_block_device {
    volume_size           = "20"
    volume_type           = "gp2"
    encrypted             = true
    delete_on_termination = true
  }

  credit_specification {
    cpu_credits = "standard"
  }

  tags = {
    "Name"        = "${var.instance_name_ovpna}"
    "Environment" = "${var.vpc_tag_environment}"
    "Type" = "network"
    "Purpose" = "vpn"
    "map-migrated"   = "d-server-001sw2ungcy573"
  }

  timeouts {
    create = "10m"
  }

}

####################################################################

# Creating Bastion EC2 Instance

####################################################################

resource "aws_instance" "bastia" {
  ami                    = var.ami_id
  instance_type          = var.instance_type                            #"t3a.micro"
  subnet_id              = aws_subnet.private_1a.id                        #module.vpc.priv_subnet_1a_id
  vpc_security_group_ids = [aws_security_group.bastion.id]
  key_name               = var.instance_name_bastiona                     #"${var.instance_name_bastiona}"

  # root disk
  root_block_device {
    volume_size           = "20"
    volume_type           = "gp2"
    encrypted             = true
    delete_on_termination = true
  }

  credit_specification {
    cpu_credits = "standard"
  }

  tags = {
    "Name"        = "${var.instance_name_bastiona}"
    "Environment" = "${var.vpc_tag_environment}"
    "map-migrated"   = "d-server-001sw2ungcy573"
    "Type" = "server"
    "Purpose" = "Bastion"
  }

  timeouts {
    create = "10m"
  }

}