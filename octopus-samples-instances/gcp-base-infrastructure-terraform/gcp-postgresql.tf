resource "google_sql_database_instance" "postgresql" {
  database_version = var.postgres_version
  region = var.octopus_gcp_region
  deletion_protection = false

  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = "db-f1-micro"

    database_flags {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }
  }
}

resource "google_sql_user" "postgres" {
  name = var.postgres_admin_username
  password = var.postgres_admin_password
  instance = google_sql_database_instance.postgresql.name
  type = "BUILT_IN"
}

resource "google_sql_user" "postgresql_service_account" {
  name = "${var.database_service_account_name}@${var.octopus_gcp_project}.iam" # Service account created in shared workers for GCP
  instance = google_sql_database_instance.postgresql.name
  type = "CLOUD_IAM_SERVICE_ACCOUNT"
}

resource "google_compute_firewall" "allow-postgresql" {
  name    = "fw-allow-postgresql"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  source_service_accounts = [ "${var.database_service_account_name}@${var.octopus_gcp_project}.iam.gserviceaccount.com" ]

}