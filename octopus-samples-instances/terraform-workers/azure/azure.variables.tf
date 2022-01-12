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

variable "octopus_azure_resourcegroup_name" {
    type = string
    default = "octopus-samples-workers"
}

variable "octopus_azure_location" {
    type = string
    default = "West US"
}

variable "octopus_azure_vm_size" {
    type = string
    default = "Standard_B2s"
}

variable "octopus_azure_vm_sku" {
    type = string
    default = "18.04-LTS"
}

variable "octopus_azure_vm_admin_username" {
    type = string
    sensitive = true
}

variable "octopus_azure_vm_admin_password" {
    type = string
    sensitive = true
}

variable "octopus_azure_vm_instance_count" {
    type = number
}

