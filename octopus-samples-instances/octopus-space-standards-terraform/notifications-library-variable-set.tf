resource "octopusdeploy_library_variable_set" "notifications_variable_set" {
  name = "Notifications TF"
  description = "Library variable set storing notification items you can leverage in your deployment process and runbook processes."
  space_id = var.octopus_space_id
}

resource "octopusdeploy_variable" "notification_variable_set_deep_link" {
  name = "Notification.Deep.Link"
  type = "String"
  
  is_sensitive = false
  value = "##{Octopus.Web.ServerUri}/app#/##{Octopus.Space.Id}/tasks/##{Octopus.Task.Id}"
  owner_id = octopusdeploy_library_variable_set.notifications_variable_set.id
}

resource "octopusdeploy_variable" "notification_variable_set_slack_channel_infrastructure" {
  name = "Notification.Infrastructure.Slack.Channel"
  type = "String"
  
  is_sensitive = false
  value = "feed-infrastructure-notifications"
  owner_id = octopusdeploy_library_variable_set.notifications_variable_set.id
}

resource "octopusdeploy_variable" "notification_variable_set_slack_channel_deployments" {
  name = "Notification.Deployments.Slack.Channel"
  type = "String"
  
  is_sensitive = false
  value = "feed-deployments-notifications"
  owner_id = octopusdeploy_library_variable_set.notifications_variable_set.id
}

resource "octopusdeploy_variable" "notification_variable_set_slack_channel_runbooks" {
  name = "Notification.Runbooks.Slack.Channel"
  type = "String"
  
  is_sensitive = false
  value = "feed-runbook-notifications"
  owner_id = octopusdeploy_library_variable_set.notifications_variable_set.id
}

resource "octopusdeploy_variable" "notification_variable_set_slack_color" {
  name = "Notification.Slack.Color"
  type = "String"
  
  is_sensitive = false
  value = "##{if Octopus.Deployment.Error}danger##{else}good##{/if}"
  owner_id = octopusdeploy_library_variable_set.notifications_variable_set.id
}

resource "octopusdeploy_variable" "notification_variable_set_slack_pending_deployment_title" {
  name = "Notification.Slack.Pending.Deployment.Title"
  type = "String"
  
  is_sensitive = false
  value = ":sleuth_or_spy: ##{Octopus.Project.Name} ##{Octopus.Release.Number} to ##{Octopus.Environment.Name} is awaiting approval."
  owner_id = octopusdeploy_library_variable_set.notifications_variable_set.id
}

resource "octopusdeploy_variable" "notification_variable_set_slack_pending_message" {
  name = "Notification.Slack.Pending.Message"
  type = "String"
  
  is_sensitive = false
  value = "##{Notification.Deep.Link}"
  owner_id = octopusdeploy_library_variable_set.notifications_variable_set.id
}

resource "octopusdeploy_variable" "notification_variable_set_slack_pending_runbook_title" {
  name = "Notification.Slack.Pending.Runbook.Title"
  type = "String"
  
  is_sensitive = false
  value = ":sleuth_or_spy: ##{Octopus.Project.Name} ##{Octopus.Runbook.Name} to ##{Octopus.Environment.Name} is awaiting approval."
  owner_id = octopusdeploy_library_variable_set.notifications_variable_set.id
}

resource "octopusdeploy_variable" "notification_variable_set_slack_status_deployment_title" {
  name = "Notification.Slack.Status.Deployment.Title"
  type = "String"
  
  is_sensitive = false
  value = "##{if Octopus.Deployment.Error}@channel :boom:##{else}:tada:##{/if} ##{Octopus.Project.Name} ##{Octopus.Release.Number} to ##{Octopus.Environment.Name} has ##{if Octopus.Deployment.Error}failed##{else}completed successfully##{/if}"
  owner_id = octopusdeploy_library_variable_set.notifications_variable_set.id
}

resource "octopusdeploy_variable" "notification_variable_set_slack_status_message" {
  name = "Notification.Slack.Status.Message"
  type = "String"
  
  is_sensitive = false
  value = "##{Notification.Deep.Link}"
  owner_id = octopusdeploy_library_variable_set.notifications_variable_set.id
}

resource "octopusdeploy_variable" "notification_variable_set_slack_status_runbook_title" {
  name = "Notification.Slack.Status.Runbook.Title"
  type = "String"
  
  is_sensitive = false
  value = "##{if Octopus.Deployment.Error}@channel :boom:##{else}:tada:##{/if} ##{Octopus.Project.Name} ##{Octopus.Runbook.Name} to ##{Octopus.Environment.Name} has ##{if Octopus.Deployment.Error}failed##{else}completed successfully##{/if}"
  owner_id = octopusdeploy_library_variable_set.notifications_variable_set.id
}

resource "octopusdeploy_variable" "notification_variable_set_slack_webhook" {
  name = "Notification.Slack.Webhook"
  type = "Sensitive" 
  is_sensitive = true 
  sensitive_value = var.octopus_notification_slack_webhook
  owner_id = octopusdeploy_library_variable_set.notifications_variable_set.id
}