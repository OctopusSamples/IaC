resource "octopusdeploy_library_variable_set" "worker_pool_variable_set" {
  name = "Worker Pools TF"
  description = "Library variable set storing worker Pools names and ids created by the Terraform Provider to use with API scripts."
}

resource "octopusdeploy_variable" "aws_worker_pool_id_variable" {
  name = "WorkerPools.AWS.Id"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = octopusdeploy_static_worker_pool.aws_worker_pool.id
  owner_id = octopusdeploy_library_variable_set.worker_pool_variable_set.id
}

resource "octopusdeploy_variable" "aws_worker_pool_name_variable" {
  name = "WorkerPools.AWS.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = var.octopus_static_aws_worker_pool_name
  owner_id = octopusdeploy_library_variable_set.worker_pool_variable_set.id
}

resource "octopusdeploy_variable" "azure_worker_pool_id_variable" {
  name = "WorkerPools.Azure.Id"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = octopusdeploy_static_worker_pool.azure_worker_pool.id
  owner_id = octopusdeploy_library_variable_set.worker_pool_variable_set.id
}

resource "octopusdeploy_variable" "azure_worker_pool_name_variable" {
  name = "WorkerPools.Azure.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = var.octopus_static_azure_worker_pool_name
  owner_id = octopusdeploy_library_variable_set.worker_pool_variable_set.id
}

resource "octopusdeploy_variable" "gcp_worker_pool_id_variable" {
  name = "WorkerPools.GCP.Id"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = octopusdeploy_static_worker_pool.gcp_worker_pool.id
  owner_id = octopusdeploy_library_variable_set.worker_pool_variable_set.id
}

resource "octopusdeploy_variable" "gcp_worker_pool_name_variable" {
  name = "WorkerPools.GCP.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = var.octopus_static_gcp_worker_pool_name
  owner_id = octopusdeploy_library_variable_set.worker_pool_variable_set.id
}