resource "octopusdeploy_library_variable_set" "gcp_variable_set" {
  name = "GCP TF"
  description = "Library variable set storing GCP specific items you can leverage in your deployment process."
}

resource "octopusdeploy_variable" "gcp_variable_set_worker_pool" {
  name = "GCP.WorkerPool"
  type = "WorkerPool"
  is_editable = true
  is_sensitive = false
  value = octopusdeploy_static_worker_pool.gcp_worker_pool.id
  owner_id = octopusdeploy_library_variable_set.gcp_variable_set.id
}