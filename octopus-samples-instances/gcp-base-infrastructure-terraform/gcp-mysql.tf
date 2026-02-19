resource "google_sql_database_instance" "mysql" {
  database_version = var.mysql_version
  region = var.octopus_gcp_region
  deletion_protection = false

  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = "db-f1-micro"

    database_flags {
      name  = "cloudsql_iam_authentication"
      value = "on"
    }

    ip_configuration {
      ipv4_enabled = true
      authorized_networks {
        name = "allow-all"
        value = "0.0.0.0/0"
    }
    }
  }

  timeouts {
    create = "30m" # Timeout for creating the instance
  }
}

resource "google_sql_user" "mysql_root" {
  name = var.mysql_admin_username
  host = "%"
  password = var.mysql_admin_password
  instance = google_sql_database_instance.mysql.name
  type = "BUILT_IN"
}

resource "google_sql_user" "mysql_service_account" {
  name = "${var.database_service_account_name}@${var.octopus_gcp_project}.iam.gserviceaccount.com" # Service account created in shared workers for GCP
  instance = google_sql_database_instance.mysql.name
  type = "CLOUD_IAM_SERVICE_ACCOUNT"
}

resource "google_compute_firewall" "allow-mysql" {
  name    = "fw-allow-mysql-${google_sql_database_instance.mysql.name}"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }

  source_service_accounts = [ "${var.database_service_account_name}@${var.octopus_gcp_project}.iam.gserviceaccount.com" ]

}