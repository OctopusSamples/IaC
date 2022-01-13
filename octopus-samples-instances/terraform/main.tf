terraform {
  required_providers {
    octopusdeploy = {
      source = "OctopusDeployLabs/octopusdeploy"
      version = "0.7.63" # example: 0.7.62
    }
  }

  backend "s3" {
    bucket = "#{Project.AWS.Backend.Bucket}"
    key = "#{Project.AWS.Backend.Key}"
    region = "#{Project.AWS.Backend.Region}"
  }
}

provider "octopusdeploy" {
  # configuration options
  address    = var.octopus_address
  api_key    = var.octopus_api_key
  space_id   = var.octopus_space_id
}

resource "octopusdeploy_feed" "github" {
  name = "GitHub Feed TF"  
  feed_type = "GitHub"
  feed_uri = "https://api.github.com"
  is_enhanced_mode = false
}

resource "octopusdeploy_feed" "feedz" {
  name = "Feedz Feed TF"  
  feed_type = "NuGet"
  feed_uri = "https://f.feedz.io/octopus-deploy-samples/octopus-samples/nuget/index.json"
}

resource "octopusdeploy_feed" "docker" {
  name = "Docker Feed TF"
  feed_type = "Docker"
  feed_uri = "https://index.docker.io"
  is_enhanced_mode = false
  download_attempts = 0
  download_retry_backoff_seconds = 0
}

resource "octopusdeploy_static_worker_pool" "aws_worker_pool" {
  name = "AWS Worker Pool TF"
  description = "Worker pool to access AWS resources.  This is managed by the Octopus Terraform Provider.  Please do not make changes in the UI, update the TF file instead."  
}

resource "octopusdeploy_static_worker_pool" "azure_worker_pool" {
  name = "Azure Worker Pool TF"
  description = "Worker pool to access Azure resources.  This is managed by the Octopus Terraform Provider.  Please do not make changes in the UI, update the TF file instead."  
}

resource "octopusdeploy_static_worker_pool" "gcp_worker_pool" {
  name = "GCP Worker Pool TF"
  description = "Worker pool to access GCP resources.  This is managed by the Octopus Terraform Provider.  Please do not make changes in the UI, update the TF file instead."  
}

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

resource "octopusdeploy_library_variable_set" "api_keys" {
  name = "API Keys TF"
  description = "API keys for the Octopus Deploy service accounts."
}

resource "octopusdeploy_variable" "azurevmss_api_key" {
  name = "APIKeys.AzureVMSS"
  type = "Sensitive"
  is_editable = true
  is_sensitive = true
  sensative_value = var.octopus_azurevmss_api_key
  owner_id = octopusdeploy_library_variable_set.api_keys.id
}