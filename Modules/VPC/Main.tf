resource "aws_vpc" "main" {
  cidr_block        = var.vpc_cidrblock
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
  cidr_block              = var.subnet_pub_1a_cidr
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
  cidr_block             = var.subnet_priv_1a_cidr
  availability_zone      = var.subnet_1a_az
  tags = {
     Name = "${var.vpc_tag_environment}_private_subnet_1a"
     Environment = var.vpc_tag_environment
     Type = var.vpc_tag_type
  }
}

resource "aws_subnet" "private_db_1a" {
  vpc_id                 = aws_vpc.main.id
  cidr_block             = var.subnet_priv_db_1a_cidr
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
  cidr_block              = var.subnet_pub_1b_cidr
  availability_zone       = var.subnet_1b_az
  tags = {
    Name = "${var.vpc_tag_environment}_public_subnet_2b"
    Environment = var.vpc_tag_environment
    Type = var.vpc_tag_type
  }
}

resource "aws_subnet" "private_1b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_priv_1b_cidr
  availability_zone       = var.subnet_1b_az
  tags = {
    Name = "${var.vpc_tag_environment}_private_subnet_1b"
    Environment = var.vpc_tag_environment
    Type = var.vpc_tag_type
  }
}

resource "aws_subnet" "private_db_1b" {
  vpc_id                 = aws_vpc.main.id
  cidr_block             = var.subnet_priv_db_1b_cidr
  availability_zone      = var.subnet_1b_az
  tags = {
     Name = "${var.vpc_tag_environment}_private_db_subnet_1b"
     Environment = var.vpc_tag_environment
     Type = var.vpc_tag_type
  }
}
















