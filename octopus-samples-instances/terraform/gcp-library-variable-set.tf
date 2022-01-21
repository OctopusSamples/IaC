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

resource "octopusdeploy_variable" "gcp_variable_project_name" {
  name = "GCP.Project.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "octopus-samples"
  owner_id = octopusdeploy_library_variable_set.gcp_variable_set.id
}

resource "octopusdeploy_variable" "gcp_variable_us_region_name" {
  name = "GCP.US.Region.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "us-central1"
  owner_id = octopusdeploy_library_variable_set.gcp_variable_set.id
}

resource "octopusdeploy_variable" "gcp_variable_us_zone_primary_name" {
  name = "GCP.US.Zone.Primary.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "us-central1-c"
  owner_id = octopusdeploy_library_variable_set.gcp_variable_set.id
}

resource "octopusdeploy_variable" "gcp_variable_us_zone_secondary_name" {
  name = "GCP.US.Zone.Secondary.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "us-central1-b"
  owner_id = octopusdeploy_library_variable_set.gcp_variable_set.id
}

resource "octopusdeploy_variable" "gcp_variable_uk_region_name" {
  name = "GCP.UK.Region.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "europe-west2"
  owner_id = octopusdeploy_library_variable_set.gcp_variable_set.id
}

resource "octopusdeploy_variable" "gcp_variable_uk_zone_primary_name" {
  name = "GCP.UK.Zone.Primary.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "europe-west2-b"
  owner_id = octopusdeploy_library_variable_set.gcp_variable_set.id
}

resource "octopusdeploy_variable" "gcp_variable_uk_zone_secondary_name" {
  name = "GCP.UK.Zone.Secondary.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "europe-west2-a"
  owner_id = octopusdeploy_library_variable_set.gcp_variable_set.id
}

resource "octopusdeploy_variable" "gcp_variable_linux_os_image" {
  name = "GCP.Instance.Linux.Image"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "ubuntu-os-cloud/ubuntu-2004-lts"
  owner_id = octopusdeploy_library_variable_set.gcp_variable_set.id
}

resource "octopusdeploy_variable" "gcp_variable_linux_default_vm_size" {
  name = "GCP.Instance.Linux.VM.Size"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "g1-small"
  owner_id = octopusdeploy_library_variable_set.gcp_variable_set.id
}

resource "octopusdeploy_variable" "gcp_variable_windows_os_image" {
  name = "GCP.Instance.Linux.Image"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "windows-cloud/windows-2019"
  owner_id = octopusdeploy_library_variable_set.gcp_variable_set.id
}

resource "octopusdeploy_variable" "gcp_variable_windows_default_vm_size" {
  name = "GCP.Instance.Windows.VM.Size"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "n1-standard-1"
  owner_id = octopusdeploy_library_variable_set.gcp_variable_set.id
}