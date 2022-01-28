resource "octopusdeploy_aws_account" "aws_account" {
  name = "AWS Account TF"
  description = "Account to access the AWS Customer Solutions sandbox.  This is managed by the Octopus Terraform Provider.  Please do not make changes in the UI, update the TF file instead."
  access_key = var.octopus_aws_account_access_key
  secret_key = var.octopus_aws_account_access_secret
}

resource "octopusdeploy_azure_service_principal" "azure_service_principal" {
  name = "Azure Service Principal Account TF"
  description = "Account to access the Azure Customer Solutions sandbox.  This is managed by the Octopus Terraform Provider.  Please do not make changes in the UI, update the TF file instead."
  application_id = var.octopus_azure_account_application_id
  subscription_id = var.octopus_azure_account_subscription_id
  tenant_id = var.octopus_azure_account_tenant_id
  password = var.octopus_azure_account_password
}

resource "octopusdeploy_gcp_account" "gcp_account" {
  json_key = var.octopus_static_gcp_worker_pool_name
  name     = "GCP Account TF"
  description = "Account to access the GCP Customer Solutions sandbox.  This is managed by the Octopus Terraform Provider.  Please do not make changes in the UI, update the TF file instead."
}