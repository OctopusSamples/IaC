resource "aws_db_subnet_group" "samples_rds_subnet_group" {
    name = "samples_rds_subnet_group"
    subnet_ids = aws_subnet.solutions-public-sb.*.id
}

resource "aws_db_parameter_group" "solutions_mariadb" {
  name = "solutions-mariadb"
  family = "mariadb10.11"
    parameter {
    name  = "log_bin_trust_function_creators"
    value = "1"
  }
}

resource "aws_db_instance" "mariadb_rds_instance" {
  allocated_storage    = 10
  engine               = "mariadb"
  instance_class       = "db.t3.micro"
  identifier = var.aws_mariadb_name
  username             = var.aws_mariadb_administrator_name
  password             = var.aws_mariadb_administrator_password
  iam_database_authentication_enabled = true
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.samples_rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.samples_security_group.id]
  parameter_group_name = aws_db_parameter_group.solutions_mariadb.name
}

resource "aws_db_instance" "mysql_rds_instance" {
  allocated_storage    = 10
  engine               = "mysql"
  instance_class       = "db.t3.micro"
  identifier = var.aws_mysql_name
  username             = var.aws_mysql_administrator_name
  password             = var.aws_mysql_administrator_password
  iam_database_authentication_enabled = true
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.samples_rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.samples_security_group.id]
}


resource "aws_db_instance" "postgresql_rds_instance" {
  allocated_storage    = 10
  engine               = "postgres"
  instance_class       = "db.t3.micro"
  identifier = var.aws_postresql_name
  username             = var.aws_postgresql_administrator_name
  password             = var.aws_postgresql_administrator_password
  iam_database_authentication_enabled = true
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.samples_rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.samples_security_group.id]
}

resource "aws_db_instance" "mssql_rds_instance" {
  allocated_storage    = 20
  engine               = "sqlserver-ex"
  instance_class       = "db.t3.small"
  identifier = var.aws_sqlserver_name
  username             = var.aws_sqlserver_administrator_name
  password             = var.aws_sqlserver_administrator_password
  skip_final_snapshot  = true
  license_model        = "license-included"
  db_subnet_group_name = aws_db_subnet_group.samples_rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.samples_security_group.id]
}
