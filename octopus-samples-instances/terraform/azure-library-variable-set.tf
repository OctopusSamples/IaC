resource "octopusdeploy_library_variable_set" "azure_variable_set" {
  name = "Azure TF"
  description = "Library variable set storing Azure specific items you can leverage in your deployment process."
}

resource "octopusdeploy_variable" "azure_variable_set_worker_pool" {
  name = "Azure.WorkerPool"
  type = "WorkerPool"
  is_editable = true
  is_sensitive = false
  value = octopusdeploy_static_worker_pool.azure_worker_pool.id
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}