variable "aws_region" {
	default = "us-east-1"
}

variable "vpc_cidr" {
	default = "10.20.0.0/16"
}

variable "subnets_cidr" {
	type = list
	default = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "azs" {
	type = list
	default = ["us-east-1a", "us-east-1b"]
}

variable "aws_postresql_name" {
    type = string
}

variable "aws_mysql_name" {
    type = string
}

variable "aws_sqlserver_name" {
	type = string
}

variable "aws_mariadb_name" {
	type = string
}

variable "aws_mysql_administrator_name" {
    type = string
}

variable "aws_mysql_administrator_password" {
    type = string
}

variable "aws_postgresql_administrator_name" {
    type = string
}

variable "aws_postgresql_administrator_password" {
    type = string
}

variable "aws_mariadb_administrator_name" {
    type = string
}

variable "aws_mariadb_administrator_password" {
    type = string
}

variable "aws_sqlserver_administrator_name" {
    type = string
}

variable "aws_sqlserver_administrator_password" {
    type = string
}

variable "octopus_cloud_static_cidr" {
    type = string
}