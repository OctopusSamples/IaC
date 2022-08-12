resource "octopusdeploy_library_variable_set" "aws_variable_set" {
  name = "AWS TF"
  description = "Library variable set storing AWS specific items you can leverage in your deployment process."
}

resource "octopusdeploy_variable" "aws_variable_set_worker_pool" {
  name = "AWS.WorkerPool"
  type = "WorkerPool"
  is_editable = true
  is_sensitive = false
  value = octopusdeploy_static_worker_pool.aws_worker_pool.id
  owner_id = octopusdeploy_library_variable_set.aws_variable_set.id
}

resource "octopusdeploy_variable" "aws_variable_account" {
  name = "AWS.Account"
  type = "AmazonWebServicesAccount"
  is_editable = true
  is_sensitive = false
  value = octopusdeploy_aws_account.aws_account.id
  owner_id = octopusdeploy_library_variable_set.aws_variable_set.id
}

resource "octopusdeploy_variable" "aws_variable_us_primary_region" {
  name = "AWS.US.Primary.Region"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "us-west-2"
  owner_id = octopusdeploy_library_variable_set.aws_variable_set.id
}

resource "octopusdeploy_variable" "aws_variable_us_secondary_region" {
  name = "AWS.US.Secondary.Region"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "us-east-1"
  owner_id = octopusdeploy_library_variable_set.aws_variable_set.id
}

resource "octopusdeploy_variable" "aws_variable_uk_primary_region" {
  name = "AWS.UK.Primary.Region"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "eu-west-2"
  owner_id = octopusdeploy_library_variable_set.aws_variable_set.id
}

resource "octopusdeploy_variable" "aws_variable_us_primary_mariadb_name" {
  name = "AWS.US.Primary.MariaDB.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "od-solutions-mariadb-uswest"
  owner_id = octopusdeploy_library_variable_set.aws_variable_set.id
}

resource "octopusdeploy_variable" "aws_variable_us_secondary_mariadb_name" {
  name = "AWS.US.Secondary.MariaDB.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "od-solutions-mariadb-useast"
  owner_id = octopusdeploy_library_variable_set.aws_variable_set.id
}

resource "octopusdeploy_variable" "aws_variable_uk_primary_mariadb_name" {
  name = "AWS.UK.Primary.MariaDB.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "od-solutions-mariadb-euwest"
  owner_id = octopusdeploy_library_variable_set.aws_variable_set.id
}

resource "octopusdeploy_variable" "aws_variable_us_primary_mysql_name" {
  name = "AWS.US.Primary.MySQL.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "od-solutions-mysql-uswest"
  owner_id = octopusdeploy_library_variable_set.aws_variable_set.id
}

resource "octopusdeploy_variable" "aws_variable_us_secondary_mysql_name" {
  name = "AWS.US.Secondary.MySQL.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "od-solutions-mysql-useast"
  owner_id = octopusdeploy_library_variable_set.aws_variable_set.id
}

resource "octopusdeploy_variable" "aws_variable_uk_primary_mysql_name" {
  name = "AWS.UK.Primary.MySQL.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "od-solutions-mysql-euwest"
  owner_id = octopusdeploy_library_variable_set.aws_variable_set.id
}

resource "octopusdeploy_variable" "aws_variable_us_primary_postgresql_name" {
  name = "AWS.US.Primary.PostgerSQL.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "od-solutions-postgresql-uswest"
  owner_id = octopusdeploy_library_variable_set.aws_variable_set.id
}

resource "octopusdeploy_variable" "aws_variable_us_secondary_postgresql_name" {
  name = "AWS.US.Secondary.PostgreSQL.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "od-solutions-postgresql-useast"
  owner_id = octopusdeploy_library_variable_set.aws_variable_set.id
}

resource "octopusdeploy_variable" "aws_variable_uk_primary_postgresql_name" {
  name = "AWS.UK.Primary.PostgreSQL.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "od-solutions-postgres-euwest"
  owner_id = octopusdeploy_library_variable_set.aws_variable_set.id
}

resource "octopusdeploy_variable" "aws_variable_us_primary_sqlserver_name" {
  name = "AWS.US.Primary.SQLServer.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "od-solutions-mssql-uswest"
  owner_id = octopusdeploy_library_variable_set.aws_variable_set.id
}

resource "octopusdeploy_variable" "aws_variable_us_secondary_sqlserver_name" {
  name = "AWS.US.Secondary.SQLServer.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "od-solutions-mssql-useast"
  owner_id = octopusdeploy_library_variable_set.aws_variable_set.id
}

resource "octopusdeploy_variable" "aws_variable_uk_primary_sqlserver_name" {
  name = "AWS.UK.Primary.SQLServer.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "od-solutions-mssql-euwest"
  owner_id = octopusdeploy_library_variable_set.aws_variable_set.id
}

resource "octopusdeploy_variable" "aws_variable_mariadb_server_admin_username" {
  name = "AWS.MariaDB.Admin.Username"
  type = "Sensitive"
  is_editable = false
  is_sensitive = true
  sensitive_value = var.octopus_aws_mariadb_admin_username
  owner_id = octopusdeploy_library_variable_set.aws_variable_set.id
}

resource "octopusdeploy_variable" "aws_variable_mariadb_server_admin_password" {
  name = "AWS.MariaDB.Admin.Password"
  type = "Sensitive"
  is_editable = false
  is_sensitive = true
  sensitive_value = var.octopus_aws_mariadb_admin_password
  owner_id = octopusdeploy_library_variable_set.aws_variable_set.id
}

resource "octopusdeploy_variable" "aws_variable_mysql_server_admin_username" {
  name = "AWS.MySQL.Admin.Username"
  type = "Sensitive"
  is_editable = false
  is_sensitive = true
  sensitive_value = var.octopus_aws_mysql_admin_username
  owner_id = octopusdeploy_library_variable_set.aws_variable_set.id
}

resource "octopusdeploy_variable" "aws_variable_mysql_server_admin_password" {
  name = "AWS.MySQL.Admin.Password"
  type = "Sensitive"
  is_editable = false
  is_sensitive = true
  sensitive_value = var.octopus_aws_mysql_admin_password
  owner_id = octopusdeploy_library_variable_set.aws_variable_set.id
}

resource "octopusdeploy_variable" "aws_variable_sql_server_admin_username" {
  name = "AWS.SQL.Admin.Username"
  type = "Sensitive"
  is_editable = false
  is_sensitive = true
  sensitive_value = var.octopus_aws_mssql_admin_username
  owner_id = octopusdeploy_library_variable_set.aws_variable_set.id
}

resource "octopusdeploy_variable" "aws_variable_sql_server_admin_password" {
  name = "AWS.SQL.Admin.Password"
  type = "Sensitive"
  is_editable = false
  is_sensitive = true
  sensitive_value = var.octopus_aws_mssql_admin_password
  owner_id = octopusdeploy_library_variable_set.aws_variable_set.id
}