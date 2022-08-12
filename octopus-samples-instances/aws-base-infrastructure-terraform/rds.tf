resource "aws_db_instance" "mariadb_rds_instance" {
  allocated_storage    = 10
  engine               = "mariadb"
  engine_version       = "10.5.12"
  instance_class       = "db.t2.micro"
  identifier = var.aws_mariadb_name
  username             = var.aws_mariadb_administrator_name
  password             = var.aws_mariadb_administrator_password
  iam_database_authentication_enabled = true
  skip_final_snapshot  = true
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
}

resource "aws_db_instance" "mssql_rds_instance" {
  allocated_storage    = 10
  engine               = "sqlserver-ee"
  instance_class       = "db.t2.micro"
  identifier = var.aws_sqlserver_name
  username             = var.aws_sqlserver_administrator_name
  password             = var.aws_sqlserver_administrator_password
  skip_final_snapshot  = true
}