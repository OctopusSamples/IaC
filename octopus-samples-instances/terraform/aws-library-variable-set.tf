resource "octopusdeploy_library_variable_set" "aws_variable_set" {
  name = "AWS TF"
  description = "Library variable set storing AWS specific items you can leverage in your deployment process."
}

resource "octopusdeploy_variable" "aws_variable_set_worker_pool" {
  name = "AWS.WorkerPool"
  type = "WorkerPool"
  is_editable = true
  is_sensitive = false
  value = octopusdeploy_static_worker_pool.aws_worker_pool.id
  owner_id = octopusdeploy_library_variable_set.aws_variable_set.id
}

resource "octopusdeploy_variable" "aws_variable_account" {
  name = "AWS.Account"
  type = "AmazonWebServicesAccount"
  is_editable = true
  is_sensitive = false
  value = octopusdeploy_aws_account.aws_account.id
  owner_id = octopusdeploy_library_variable_set.aws_variable_set.id
}