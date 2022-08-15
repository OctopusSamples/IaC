resource "aws_db_subnet_group" "samples_rds_subnet_group" {
    name = "samples_rds_subnet_group"
    subnet_ids = aws_subnet.solutions-public-sb.*.id
}


resource "aws_db_instance" "mariadb_rds_instance" {
  allocated_storage    = 10
  engine               = "mariadb"
  engine_version       = "10.6.8"
  instance_class       = "db.t2.micro"
  identifier = var.aws_mariadb_name
  username             = var.aws_mariadb_administrator_name
  password             = var.aws_mariadb_administrator_password
  iam_database_authentication_enabled = true
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.samples_rds_subnet_group.name
}

resource "aws_db_instance" "mysql_rds_instance" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7.26"
  instance_class       = "db.t2.micro"
  identifier = var.aws_mysql_name
  username             = var.aws_mysql_administrator_name
  password             = var.aws_mysql_administrator_password
  iam_database_authentication_enabled = true
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.samples_rds_subnet_group.name
}

resource "aws_db_instance" "postgresql_rds_instance" {
  allocated_storage    = 10
  engine               = "postgres"
  engine_version       = "11.14"
  instance_class       = "db.t2.micro"
  identifier = var.aws_postresql_name
  username             = var.aws_postgresql_administrator_name
  password             = var.aws_postgresql_administrator_password
  iam_database_authentication_enabled = true
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.samples_rds_subnet_group.name
}

resource "aws_db_instance" "mssql_rds_instance" {
  allocated_storage    = 10
  engine               = "sqlserver-ex"
  engine_version = "15.00.4198.2.v1"
  instance_class       = "db.t3.small"
  identifier = var.aws_sqlserver_name
  username             = var.aws_sqlserver_administrator_name
  password             = var.aws_sqlserver_administrator_password
  skip_final_snapshot  = true
  license_model        = "license-included"
  db_subnet_group_name = aws_db_subnet_group.samples_rds_subnet_group.name
}