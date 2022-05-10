resource "google_service_account" "database_service_account" {
  account_id   = var.database_service_account_name
  display_name = "Database Service Account"
}

resource "google_project_iam_member" "service_account_role" {
    project = var.gcp_project
    role = "roles/cloudsql.instanceUser"
    member = "serviceAccount:${google_service_account.database_service_account.email}"
}
