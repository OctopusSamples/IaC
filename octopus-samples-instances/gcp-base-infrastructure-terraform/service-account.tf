resource "google_service_account" "database_service_account" {
  account_id   = var.database_service_account_name
  display_name = "Database Service Account"
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [google_service_account.database_service_account]

  create_duration = "30s"
}

resource "google_project_iam_member" "service_account_role" {
    project = var.octopus_gcp_project
    role = "roles/cloudsql.instanceUser"
    member = "serviceAccount:${google_service_account.database_service_account.email}"
}
