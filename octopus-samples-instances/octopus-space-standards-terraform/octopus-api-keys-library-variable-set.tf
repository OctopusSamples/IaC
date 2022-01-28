resource "octopusdeploy_library_variable_set" "api_key_variable_set" {
  name = "API Keys TF"
  description = "Library variable set storing Octopus api keys for service accounts that can be used in scripts."
}

resource "octopusdeploy_variable" "api_key_variable_AzureVMSS" {
  name = "APIKeys.Samples.AzureVMSS"
  type = "Sensitive"
  is_editable = false
  is_sensitive = true
  value = var.octopus_azurevmss_api_key
  owner_id = octopusdeploy_library_variable_set.api_key_variable_set.id
}

resource "octopusdeploy_variable" "api_key_variable_AWSAutoScaling" {
  name = "APIKeys.Samples.AWSAutoScaling"
  type = "Sensitive"
  is_editable = false
  is_sensitive = true
  value = var.octopus_awsautoscaling_api_key
  owner_id = octopusdeploy_library_variable_set.api_key_variable_set.id
}

resource "octopusdeploy_variable" "api_key_variable_ReleseConductor" {
  name = "APIKeys.Samples.ReleaseConductor"
  type = "Sensitive"
  is_editable = false
  is_sensitive = true
  value = var.octopus_releaseconductor_api_key
  owner_id = octopusdeploy_library_variable_set.api_key_variable_set.id
}

resource "octopusdeploy_variable" "api_key_variable_CertificateUser" {
  name = "APIKeys.Samples.CertificateUser"
  type = "Sensitive"
  is_editable = false
  is_sensitive = true
  value = var.octopus_certificateuser_api_key
  owner_id = octopusdeploy_library_variable_set.api_key_variable_set.id
}

resource "octopusdeploy_variable" "api_key_variable_InfrastructureUser" {
  name = "APIKeys.Samples.InfrastructureUser"
  type = "Sensitive"
  is_editable = false
  is_sensitive = true
  value = var.octopus_infrastructureuser_api_key
  owner_id = octopusdeploy_library_variable_set.api_key_variable_set.id
}