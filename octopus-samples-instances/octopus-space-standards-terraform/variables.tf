variable "octopus_address" {
    type = string
}

variable "octopus_api_key" {
    type = string
}

variable "octopus_space_id" {
    type = string
}

variable "octopus_aws_account_access_key" {
    type = string
}

variable "octopus_aws_account_access_secret" {
    type = string
    sensitive = true
}

variable "octopus_azure_account_application_id" {
    type = string
}

variable "octopus_azure_account_subscription_id" {
    type = string
}

variable "octopus_azure_account_tenant_id" {
    type = string
}

variable "octopus_azure_account_password" {
    type = string
    sensitive = true
}

variable "octopus_gcp_account_json_key" {
    type = string
    sensitive = true
}

variable "octopus_sql_server_sample_admin_password" {
    type = string
    sensitive = true
}

variable "octopus_sql_server_sample_admin_username" {
    type = string
    sensitive = true
}

variable "octopus_postgresql_server_sample_admin_password" {
    type = string
    sensitive = true
}

variable "octopus_postgresql_server_sample_admin_username" {
    type = string
    sensitive = true
}

variable "octopus_mysql_server_sample_admin_password" {
    type = string
    sensitive = true
}

variable "octopus_mysql_server_sample_admin_username" {
    type = string
    sensitive = true
}

variable "octopus_static_aws_worker_pool_name" {
    type = string
    default = "AWS Worker Pool TF"
}

variable "octopus_static_azure_worker_pool_name" {
    type = string
    default = "Azure Worker Pool TF"
}

variable "octopus_static_gcp_worker_pool_name" {
    type = string
    default = "GCP Worker Pool TF"
}

variable "octopus_static_aws_windows_worker_pool_name" {
    type = string
    default = "AWS Windows Worker Pool TF"
}

variable "octopus_static_azure_windows_worker_pool_name" {
    type = string
    default = "Azure Windows Worker Pool TF"
}

variable "octopus_azurevmss_api_key" {
    type = string
    sensitive = true
}

variable "octopus_awsautoscaling_api_key" {
    type = string
    sensitive = true
}

variable "octopus_releaseconductor_api_key" {
    type = string
    sensitive = true
}

variable "octopus_certificateuser_api_key" {
    type = string
    sensitive = true
}

variable "octopus_infrastructureuser_api_key" {
    type = string
    sensitive = true
}

variable "octopus_notification_slack_webhook" {
    type = string
}

variable "octopus_gcp_database_service_account_name" {
    type = string
    default = "db-service-account"
}

variable "octopus_gcp_postgresql_admin_username" {
    type = string
    sensitive = true
}

variable "octopus_gcp_postgresql_admin_password" {
    type = string
    sensitive = true
}

variable "octopus_gcp_mysql_admin_username" {
    type = string
    sensitive = true
}

variable "octopus_gcp_mysql_admin_password" {
    type = string
    sensitive = true
}

variable "octopus_gcp_mssql_admin_username" {
    type = string
    sensitive = true
}

variable "octopus_gcp_mssql_admin_password" {
    type = string
    sensitive = true
}

variable "octopus_aws_postgresql_admin_username" {
    type = string
    sensitive = true
}

variable "octopus_aws_postgresql_admin_password" {
    type = string
    sensitive = true
}

variable "octopus_aws_mysql_admin_username" {
    type = string
    sensitive = true
}

variable "octopus_aws_mysql_admin_password" {
    type = string
    sensitive = true
}

variable "octopus_aws_mssql_admin_username" {
    type = string
    sensitive = true
}

variable "octopus_aws_mssql_admin_password" {
    type = string
    sensitive = true
}

variable "octopus_aws_mariadb_admin_username" {
    type = string
    sensitive = true
}

variable "octopus_aws_mariadb_admin_password" {
    type = string
    sensitive = true
}

variable "octopus_feed_dockerhub_username" {
    type = string
}

variable "octopus_feed_dockerhub_password" {
    type = string
    sensitive = true
}

variable "octopus_feed_ghcr_username" {
    type = string
}

variable "octpopus_feed_ghcr_password" {
    type = string
    sensitive = true
}