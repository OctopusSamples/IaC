variable "tags" {
  type = map(string)
  default = {
    LifeTimeInDays = "6"
  }
}

variable "octopus_azure_account_application_id" {
    type = string
    default = "#{SpaceStandard.Azure.Account.ApplicationId}"
}

variable "octopus_azure_account_subscription_id" {
    type = string
    default = "#{SpaceStandard.Azure.Account.SubscriptionId}"
}

variable "octopus_azure_account_tenant_id" {
    type = string
    default = "#{SpaceStandard.Azure.Account.TenantId}"
}

variable "octopus_azure_account_password" {
    type = string
    sensitive = true
    default = "#{SpaceStandard.Azure.Account.Password}"
}

variable "octopus_azure_resourcegroup_name" {
    type = string
    default = "#{Project.Azure.ResourceGroup.Name}"
}

variable "octopus_azure_location" {
    type = string
    default = "#{Project.Azure.Region.Name}"
}

variable "octopus_azure_vm_size" {
    type = string
    default = "#{Project.Azure.VM.Size}"
}

variable "octopus_azure_vm_sku" {
    type = string
    default = "#{Project.Azure.VM.Sku}"
}

variable "octopus_azure_vm_admin_username" {
    type = string
    sensitive = true
    default = "#{Project.Azure.VM.Admin.Username}"
}

variable "octopus_azure_vm_admin_password" {
    type = string
    sensitive = true
    default = "#{Project.Azure.VM.Admin.Password}"
}

variable "octopus_azure_vm_instance_count" {
    type = number
    default = "#{Project.Azure.VM.Instance.Count}"
}

variable "octopus_azure_scaleset_name" {
    type = string
    default = "#{Project.Azure.ScaleSet.Name}"
}

