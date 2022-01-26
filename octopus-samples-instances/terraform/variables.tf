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