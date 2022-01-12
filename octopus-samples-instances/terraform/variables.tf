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

variable "octopus_azurevmss_api_key" {
    type = string
    sensitive = true
}