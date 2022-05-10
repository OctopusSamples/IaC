variable "octopus_gcp_admin_username" {
    type = string
    default = "octoadmin"
}

variable "octopus_gcp_admin_password" {
    type = string
    sensitive = true
}

variable "octopus_gcp_project" {
    type = string
    default = "octopus-samples"
}

variable "octopus_gcp_zone" {
    type = string
    default = "us-central1-a"
}

variable "octopus_gcp_region" {
    type = string
    default = "us-central1"
}

variable "mysql_version" {
    type = string
    default = "MYSQL_8_0"
}

variable "mysql_admin_password" {
    type = string
    sensitive = true
}

variable "mysql_admin_username" {
    type = string
    default = "root"
}

variable "postgres_admin_password" {
    type = string
    sensitive = true
}

variable "postgres_admin_username" {
    type = string
    default = "postgres"
}

variable "postgres_version" {
    type = string
    default = "POSTGRES_13"
}

variable "mssql_version" {
    type = string
    default = "SQLSERVER_2019_EXPRESS"
}

variable "mssql_admin_username" {
    type = string
    sensitive = true
}

variable "mssql_admin_password" {
    type = string
    sensitive = true
}

variable "database_service_account_name" {
  description = "Name of the service account to access databases"
  type = string
}