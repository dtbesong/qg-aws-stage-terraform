resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  instance_tenancy  = "default"
  enable_dns_support = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = var.vpc_tag_name
    Environment = var.vpc_tag_environment
    Type = var.vpc_tag_type
    Purpose = var.vpc_tag_purpose
  }
}

###################################################
###################### EIP ########################
###################################################
resource "aws_eip" "ngw_ip_a" {
  vpc = true
}

###################################################
################### Gateways ######################
###################################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main_internet_gateway"
    Environment = var.vpc_tag_environment
    Type = var.vpc_tag_type
  }
}

resource "aws_nat_gateway" "ngw_a" {
  allocation_id = aws_eip.ngw_ip_a.id
  subnet_id = aws_subnet.public_1a.id
  tags = {
    Name = "Nat Gateway A"
    Environment = var.vpc_tag_environment
    Type = var.vpc_tag_type
  }
}


###################################################
################# Route Tables ####################
###################################################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.vpc_tag_environment}_VPC_Public_Route"
    Type = var.vpc_tag_type
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_1b.id
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.vpc_tag_environment}_VPC_Private_Route_A"
    Type = var.vpc_tag_type
  }
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw_a.id
  }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_1a.id
  route_table_id = aws_route_table.private_a.id
}

resource "aws_route_table_association" "private_db_a" {
  subnet_id      = aws_subnet.private_db_1a.id
  route_table_id = aws_route_table.private_a.id
}

resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.vpc_tag_environment}_VPC_Private_Route_B"
  }
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_1b.id
  route_table_id = aws_route_table.private_b.id
}

resource "aws_route_table_association" "private_db_b" {
  subnet_id      = aws_subnet.private_db_1b.id
  route_table_id = aws_route_table.private_b.id
}



###################################################
############ Subnets for us-east-1a ###############
###################################################
resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_pub_1a_cidr_block
  map_public_ip_on_launch = "true"
  availability_zone       = var.subnet_1a_az
  tags = {
   Name = "${var.vpc_tag_environment}_public_subnet_1a"
   Environment = var.vpc_tag_environment
   Type = var.vpc_tag_type
  }
}

resource "aws_subnet" "private_1a" {
  vpc_id                 = aws_vpc.main.id
  cidr_block             = var.subnet_priv_1a_cidr_block
  availability_zone      = var.subnet_1a_az
  tags = {
     Name = "${var.vpc_tag_environment}_private_subnet_1a"
     Environment = var.vpc_tag_environment
     Type = var.vpc_tag_type
  }
}

resource "aws_subnet" "private_db_1a" {
  vpc_id                 = aws_vpc.main.id
  cidr_block             = var.subnet_priv_db_1a_cidr_block
  availability_zone      = var.subnet_1a_az
  tags = {
     Name = "${var.vpc_tag_environment}_private_db_subnet_1a"
     Environment = var.vpc_tag_environment
     Type = var.vpc_tag_type
  }
}

###################################################
############ Subnets for us-east-1b ###############
###################################################
resource "aws_subnet" "public_1b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_pub_1b_cidr_block
  availability_zone       = var.subnet_1b_az
  tags = {
    Name = "${var.vpc_tag_environment}_public_subnet_2b"
    Environment = var.vpc_tag_environment
    Type = var.vpc_tag_type
  }
}

resource "aws_subnet" "private_1b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_priv_1b_cidr_block
  availability_zone       = var.subnet_1b_az
  tags = {
    Name = "${var.vpc_tag_environment}_private_subnet_1b"
    Environment = var.vpc_tag_environment
    Type = var.vpc_tag_type
  }
}

resource "aws_subnet" "private_db_1b" {
  vpc_id                 = aws_vpc.main.id
  cidr_block             = var.subnet_priv_db_1b_cidr_block
  availability_zone      = var.subnet_1b_az
  tags = {
     Name = "${var.vpc_tag_environment}_private_db_subnet_1b"
     Environment = var.vpc_tag_environment
     Type = var.vpc_tag_type
  }
}












###################################################
################# Security ########################
###################################################



###################################################
#################  Aurora RDS Security Group ######
###################################################
resource "aws_security_group" "rds" {
  name        = "${var.vpc_tag_environment}-security-group-rds"
  description = "Allow MySQL 3306 from local networks"
  vpc_id      = aws_vpc.main.id                                          #module.vpc.vpc_main_id

  ingress {
    description = "Allow MYSQL traffic from ${var.vpc_tag_environment} apps"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = ["${aws_security_group.app.id}"]
  }

  ingress {
    description = "Allow MYSQL traffic from ${var.vpc_tag_environment} bastion server"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = ["${aws_security_group.bastion.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_tag_environment}-security-group-rds"
    Type = var.vpc_tag_type
    Environment = var.vpc_tag_environment
  }
}

###################################################
#############  App Security Group  ################
###################################################

resource "aws_security_group" "app" {
  name        = "${var.vpc_tag_environment}-security-group-bat-app"
  description = "Allow access from Load balancers to web applications using HTTPS"
  vpc_id      = aws_vpc.main.id                                                              #module.vpc.vpc_main_id

  ingress {
    description = "Allow HTTPS from ALB Security Group"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = ["${aws_security_group.alb.id}"]
  }

  ingress {
    description = "Allow SSH from Bastion Server"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = ["${aws_security_group.bastion.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_tag_environment}-security-group-bat-app"
    Type = var.vpc_tag_type
    Environment = var.vpc_tag_environment
  }
}

###################################################
#############  OpenVPN Security Group  ############
###################################################

resource "aws_security_group" "openvpn" {
  name        = "${var.vpc_tag_environment}-security-group-openvpn"
  description = "Allow necessary connections to OpenVPN"
  vpc_id      =  aws_vpc.main.id                                                                 #module.vpc.vpc_main_id

  ingress {
    description = "Allow HTTPS used by OpenVPN Access Server for the Client Web Server"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS for the use of the Admin Web UI"
    from_port   = 943
    to_port     = 943
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow connects used by the client to intitiate VPN sessions "
    from_port   = 1194
    to_port     = 1194
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow ssh to the server from the CMD Office to complete the initial setup and config"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["66.55.50.26/32"]
  }
  
  ingress {
    description = "Allow HTTP access from anywhere for the Lets Encrypt / Certbot Certificate Setup"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_tag_environment}-security-group-openvpn"
    Type = var.vpc_tag_type
    Environment = var.vpc_tag_environment
  }
}

###################################################
#############  ALB Security Group  ################
###################################################

resource "aws_security_group" "alb" {
  name        = "${var.vpc_tag_environment}-security-group-alb"
  description = "Allow HTTP and HTTPS from anywhere to ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTPPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTPP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_tag_environment}-security-group-alb"
    Type = var.vpc_tag_type
    Environment = var.vpc_tag_environment
  }
}

###################################################
#############  Bastion Server Security Group  #####
###################################################

resource "aws_security_group" "bastion" {
  name        = "${var.vpc_tag_environment}-security-group-bastion"
  description = "Allow SSH to the Bastion Server from OpenVPN"
  vpc_id      = aws_vpc.main.id                                                    #module.vpc.vpc_main_id

  ingress {
    description = "Allow SSH from the OpenVPN Server"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = ["${aws_security_group.openvpn.id}"]
  }

  ingress {
    description = "Allow SSH from app servers for secure file copy"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.subnet_priv_1a_cidr_block,var.subnet_priv_1b_cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_tag_environment}-security-group-bastion"
    Type = var.vpc_tag_type
    Environment = var.vpc_tag_environment
  }
}








resource "aws_network_acl" "private_app" {
  vpc_id = aws_vpc.main.id                                                   #module.vpc.vpc_main_id
  subnet_ids = [aws_subnet.private_1a.id,aws_subnet.private_1b.id]                 #[module.vpc.priv_subnet_1a_id,module.vpc.priv_subnet_1b_id]

###################################################
#################### Ingress ######################
###################################################
  ingress {
    rule_no = 10
    action = "allow"
    from_port = 0
    to_port = 0
    icmp_code = 0
    icmp_type = 0
    protocol = "all"
    cidr_block = "0.0.0.0/0"
  }






###################################################
#################### Egress #######################
###################################################

  egress {
    rule_no = 10
    action = "allow"
    from_port = 0
    to_port = 0
    icmp_code = 0
    icmp_type = 0
    protocol = "all"
    cidr_block = "0.0.0.0/0"
  }

  tags = {
   Name = "${var.vpc_tag_environment}-Private_App_ACL"
   Type = var.vpc_tag_type
   Environment = var.vpc_tag_environment
 }
}




















resource "aws_network_acl" "private_db" {
  vpc_id = aws_vpc.main.id                                                       #module.vpc.vpc_main_id
  subnet_ids = [aws_subnet.private_db_1a.id,aws_subnet.private_db_1b.id]                                                        #[module.vpc.priv_db_subnet_1a_id,module.vpc.priv_db_subnet_1b_id]

###################################################
#################### Ingress ######################
###################################################
  ingress {
    rule_no = 10
    action = "allow"
    from_port = 0
    to_port = 0
    icmp_code = 0
    icmp_type = 0
    protocol = "all"
    cidr_block = var.subnet_priv_1a_cidr_block
  }
  ingress {
    rule_no = 20
    action = "allow"
    from_port = 0
    to_port = 0
    icmp_code = 0
    icmp_type = 0
    protocol = "all"
    cidr_block = var.subnet_priv_1b_cidr_block
  }
  #ingress {
  #  rule_no = 30
  #  action = "allow"
  #  from_port = 3306
  #  to_port = 3306
  #  icmp_code = 0
  #  icmp_type = 0
  #  protocol = "tcp"
  #  cidr_block = "10.20.10.244/32"
  #}



###################################################
#################### Egress #######################
###################################################
  egress {
    rule_no = 10
    action = "allow"
    from_port = 0
    to_port = 0
    icmp_code = 0
    icmp_type = 0
    protocol = "all"
    cidr_block = "0.0.0.0/0"
  }

  tags = {
   Name = "${var.vpc_tag_environment}-Private_DB_ACL"
   Type = var.vpc_tag_type
   Environment = var.vpc_tag_environment
 }
}













resource "aws_network_acl" "pub_acl" {
  vpc_id = aws_vpc.main.id                                                     #module.vpc.vpc_main_id
  subnet_ids = [aws_subnet.public_1a.id,aws_subnet.public_1b.id]                          #[module.vpc.pub_subnet_1a_id,module.vpc.pub_subnet_1b_id]

###################################################
#################### Ingress ######################
###################################################
  ingress {
    rule_no = 10
    action = "allow"
    from_port = 0
    to_port = 0
    icmp_code = 0
    icmp_type = 0
    protocol = "all"
    cidr_block = "0.0.0.0/0"
  }


###################################################
#################### Egress #######################
###################################################

  egress {
    rule_no = 10
    action = "allow"
    from_port = 0
    to_port = 0
    icmp_code = 0
    icmp_type = 0
    protocol = "all"
    cidr_block = "0.0.0.0/0"
  }

  tags = {
   Name = "${var.vpc_tag_environment}-Public_ACL"
   Type = var.vpc_tag_type
   Environment = var.vpc_tag_environment
 }
}





















