Modules "project1-vpc" {
    source = "../Modules/vpc"
    
    

    vpc_cidrblock = var.p1_vpc_cidrblock
    subnet_pub_1a_cidr = var.p1_subnet_pub_1a_cidr
    subnet_priv_1a_cidr = var.p1_subnet_priv_1a_cidr
    subnet_priv_db_1a_cidr = var.p1_subnet_priv_db_1a_cidr
    subnet_pub_1b_cidr = var.p1_subnet_pub_1b_cidr
    subnet_priv_1b_cidr = var.p1_subnet_priv_1b_cidr
    subnet_priv_db_1b_cidr = var.p1_subnet_priv_db_1b_cidr
    vpc_tag_name = var.p1_vpc_tag_name
    vpc_tag_environment = var.p1_vpc_tag_environment
    vpc_tag_type = var.p1_vpc_tag_type
    vpc_tag_purpose = var.p1_vpc_tag_purpose
    subnet_1a_az = var.p1_subnet_1a_az
    subnet_1b_az = var.p1_subnet_1b_az

}


###################################################
#######  ALB ACCESS LOG BUCKET AND POLICY  ########
###################################################
data "aws_region" "current" {}
data "aws_elb_service_account" "main" {}
resource "aws_s3_bucket_policy" "lb-bucket-policy" {
  bucket = aws_s3_bucket.elb_logs.id

  policy = <<POLICY
{
    "Id": "Policy",
    "Version": "2012-10-17",
    "Statement": [{
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "${data.aws_elb_service_account.main.arn}"
                ]
            },
            "Action": [
                "s3:PutObject"
            ],
            "Resource": "${aws_s3_bucket.elb_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "delivery.logs.amazonaws.com"
            },
            "Action": [
                "s3:PutObject"
            ],
            "Resource": "${aws_s3_bucket.elb_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        },
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "delivery.logs.amazonaws.com"
            },
            "Action": [
                "s3:GetBucketAcl"
            ],
            "Resource": "${aws_s3_bucket.elb_logs.arn}"
        }
    ]
}
POLICY
}

resource "aws_s3_bucket" "elb_logs" {
  bucket = "qg-${var.vpc_tag_environment}-elb-accesslogs-s3ue1"
  acl    = "private"

  lifecycle_rule {
    enabled = true
    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

###################################################
################  VPC FLOW LOGS  ##################
###################################################
/*
resource "aws_s3_bucket" "vpc_flow_logs" {
  bucket = "qg-${var.vpc_tag_environment}-1-vpc-flowlogs-s3ue1"
  acl    = "private"
  lifecycle_rule {
    enabled = true

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    transition {
      days          = 180
      storage_class = "DEEP_ARCHIVE"
    }

    expiration {
      days = 2570
    }
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
*/

###################################################
##############  CLOUDTRAIL BUCKET  ################
###################################################

resource "aws_s3_bucket" "tf-cloudtrail-events" {
  bucket        = local.aws_s3_bucket
  force_destroy = true
  lifecycle_rule {
    enabled = true

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    transition {
      days          = 180
      storage_class = "DEEP_ARCHIVE"
    }

    expiration {
      days = 2570
    }
  }

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${local.aws_s3_bucket}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${local.aws_s3_bucket}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_s3_bucket_public_access_block" "tf-cloudtrail-events" {
  bucket = local.aws_s3_bucket

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}


















###################################################
################## Cloudtrail #####################
###################################################


resource "aws_iam_role" "tf-cloudtrail-events" {
  name = "CloudTrailRoleForCloudwatchLogs"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "tf-cloudtrail-events" {
  name = "CloudTrailPlolicyForCloudwatchLogs"
  role = aws_iam_role.tf-cloudtrail-events.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AWSCloudTrailCreateLogStream",
      "Effect": "Allow",
      "Action": ["logs:CreateLogStream"],
      "Resource": [
          "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.cloudtrail-events.id}:log-stream:*"


      ]
    },
    {
      "Sid": "AWSCloudTrailPutLogEvents",
      "Effect": "Allow",
      "Action": ["logs:PutLogEvents"],
      "Resource": [
	"arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.cloudtrail-events.id}:log-stream:*"
      ]
    }
  ]
}
EOF
}



###################################################
################## Cloudtrail #####################
###################################################


resource "aws_iam_role" "tf-cloudtrail-events" {
  name = "CloudTrailRoleForCloudwatchLogs"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "tf-cloudtrail-events" {
  name = "CloudTrailPlolicyForCloudwatchLogs"
  role = aws_iam_role.tf-cloudtrail-events.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AWSCloudTrailCreateLogStream",
      "Effect": "Allow",
      "Action": ["logs:CreateLogStream"],
      "Resource": [
          "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.cloudtrail-events.id}:log-stream:*"


      ]
    },
    {
      "Sid": "AWSCloudTrailPutLogEvents",
      "Effect": "Allow",
      "Action": ["logs:PutLogEvents"],
      "Resource": [
	"arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.cloudtrail-events.id}:log-stream:*"
      ]
    }
  ]
}
EOF
}






data "aws_caller_identity" "current" {}

#output "account_id" {
#  value = data.aws_caller_identity.current.account_id
#}

resource "aws_cloudtrail" "tf-cloudtrail-events" {
  name                          = "All-Regions-All-Read-Writes"
  s3_bucket_name                = aws_s3_bucket.tf-cloudtrail-events.id
  is_multi_region_trail 	= true
  enable_logging		= true
  enable_log_file_validation 	= true
  include_global_service_events = true                                    #added to capture trails for global services like IAM
  kms_key_id 			= aws_kms_key.tf-cloudtrail-events.arn
  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail-events.arn}:*"
  cloud_watch_logs_role_arn = aws_iam_role.tf-cloudtrail-events.arn

}

###################################################
#################  CW Log Group  ##################
###################################################

resource "aws_cloudwatch_log_group" "cloudtrail-events" {
  name = "Cloudtrail/AllManagementLogGroup"
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
    cidr_blocks = [var.subnet_priv_1a_cidr,var.subnet_priv_1b_cidr]
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













######################################################
############### aws_kms_key ##########################
######################################################




resource "aws_kms_key" "tf-cloudtrail-events" {
  description         = "KMS key for tf-cloudtrail-events"
  policy              = <<EOF
{
    "Version": "2012-10-17",
    "Id": "Key policy created by CloudTrail",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Allow CloudTrail to encrypt logs",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "kms:GenerateDataKey*",
            "Resource": "*",
            "Condition": {
                "StringLike": {
                    "kms:EncryptionContext:aws:cloudtrail:arn": "arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"
                }
            }
        },
        {
            "Sid": "Allow CloudTrail to describe key",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "kms:DescribeKey",
            "Resource": "*"
        },
        {
            "Sid": "Allow principals in the account to decrypt log files",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": [
                "kms:Decrypt",
                "kms:ReEncryptFrom"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "kms:CallerAccount": "${data.aws_caller_identity.current.account_id}"
                },
                "StringLike": {
                    "kms:EncryptionContext:aws:cloudtrail:arn": "arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"
                }
            }
        },
        {
            "Sid": "Allow alias creation during setup",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": "kms:CreateAlias",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "kms:CallerAccount": "${data.aws_caller_identity.current.account_id}",
                    "kms:ViaService": "ec2.us-east-1.amazonaws.com"
                }
            }
        },
        {
            "Sid": "Enable cross account log decryption",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": [
                "kms:Decrypt",
                "kms:ReEncryptFrom"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "kms:CallerAccount": "${data.aws_caller_identity.current.account_id}"
                },
                "StringLike": {
                    "kms:EncryptionContext:aws:cloudtrail:arn": "arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"
                }
            }
        }
    ]
}
EOF
}


resource "aws_kms_alias" "tf-cloudtrail-events" {
  name          = "alias/tf-cloudtrail-events"
  target_key_id = aws_kms_key.tf-cloudtrail-events.key_id
}



















resource "aws_network_acl" "private_app" {
  vpc_id = aws_vpc.main.id                                                   #module.vpc.vpc_main_id
  subnet_ids = [aws_subnets.private_1a.id,aws_subnet.private_1b.id]                 #[module.vpc.priv_subnet_1a_id,module.vpc.priv_subnet_1b_id]

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
    cidr_block = var.subnet_priv_1a_cidr
  }
  ingress {
    rule_no = 20
    action = "allow"
    from_port = 0
    to_port = 0
    icmp_code = 0
    icmp_type = 0
    protocol = "all"
    cidr_block = var.subnet_priv_1b_cidr
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
