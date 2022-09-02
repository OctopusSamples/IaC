resource "octopusdeploy_static_worker_pool" "aws_worker_pool" {
  name = var.octopus_static_aws_worker_pool_name
  description = "Worker pool to access AWS resources.  This is managed by the Octopus Terraform Provider.  Please do not make changes in the UI, update the TF file instead."  
}

resource "octopusdeploy_static_worker_pool" "azure_worker_pool" {
  name = var.octopus_static_azure_worker_pool_name
  description = "Worker pool to access Azure resources.  This is managed by the Octopus Terraform Provider.  Please do not make changes in the UI, update the TF file instead."  
}

resource "octopusdeploy_static_worker_pool" "gcp_worker_pool" {
  name = var.octopus_static_gcp_worker_pool_name
  description = "Worker pool to access GCP resources.  This is managed by the Octopus Terraform Provider.  Please do not make changes in the UI, update the TF file instead."  
}

resource "octopusdeploy_static_worker_pool" "aws_windows_worker_pool" {
  name = var.octopus_static_aws_windows_worker_pool_name
  description = "Windows worker pool to access AWS resources.  This is managed by the Octopus Terraform Provider.  Please do not make changes in the UI, update the TF file instead."
}

resource "octopusdeploy_static_worker_pool" "azure_windows_worker_pool" {
  name = var.octopus_static_azure_windows_worker_pool_name
  description = "Windows worker pool to access Azure resources.  This is managed by the Octopus Terraform Provider.  Please do not make changes in the UI, update the TF file instead."
}