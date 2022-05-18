resource "aws_db_instance" "qg_mysql" {
  allocated_storage       = "30"
  engine                  = "mysql"
  engine_version          = "5.7"
  instance_class          = "db.t3.medium"
  db_subnet_group_name    = "${aws_db_subnet_group.dev.name}"
  name                    = "qgdevmysql001"
  identifier              = "qgdevdb001"
  username         = jsondecode(data.aws_secretsmanager_secret_version.currentuser.secret_string)["username"]
  password         = jsondecode(data.aws_secretsmanager_secret_version.currentuser.secret_string)["password"]
  backup_retention_period = 3
  backup_window = "07:00-09:00"
  maintenance_window = "Sun:00:00-Sun:03:00"
  skip_final_snapshot  = true
  storage_encrypted          = true
  auto_minor_version_upgrade = true
  vpc_security_group_ids = ["${aws_security_group.rds.id}"]
  multi_az = false

# Database Deletion Protection
  deletion_protection = true

  depends_on = [
    aws_db_subnet_group.dev,
  ]
}

resource "aws_db_subnet_group" "dev" {
  name       = "subnet-group-qg-mysql001"
  subnet_ids = [module.vpc.priv_db_subnet_1a_id,module.vpc.priv_db_subnet_1b_id]
  description = "Dev Private Database subnet group for MySQL database"

  tags = {
    Name = "${var.vpc_tag_environment}_subnet-group-qg-mysql001"
    Environment = var.vpc_tag_environment
    Type = var.vpc_tag_type
    Purpose = "rds"
  }
}

data "aws_secretsmanager_secret" "secretuser" {
  arn = "arn:aws:secretsmanager:us-east-1:483935165063:secret:dev/mysql/admin-dfKzkO"
}

data "aws_secretsmanager_secret_version" "currentuser" {
  secret_id = data.aws_secretsmanager_secret.secretuser.id
}
