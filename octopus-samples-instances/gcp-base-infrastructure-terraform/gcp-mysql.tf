resource "google_sql_database_instance" "mysql" {
  database_version = var.mysql_version
  region = var.octopus_gcp_region
  #root_password = var.octopus_gcp_admin_password
  deletion_protection = false

  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = "db-f1-micro"

    database_flags {
      name  = "cloudsql_iam_authentication"
      value = "on"
    }
  }
}

resource "google_sql_user" "mysql_google_user_shawn_sesna" {
  name     = "shawn.sesna@octopus.com"
  instance = google_sql_database_instance.mysql.name
  type     = "CLOUD_IAM_USER"
}

resource "google_sql_user" "mysql_root" {
  name = var.mysql_admin_username
  host = "%"
  password = var.mysql_admin_password
  instance = google_sql_database_instance.mysql.name
  type = "BUILT_IN"
}

resource "google_sql_user" "mysql_service_account" {
  name = "db-service-account@octopus-samples.iam.gserviceaccount.com" # Service account created in shared workers for GCP
  instance = google_sql_database_instance.mysql.name
  type = "CLOUD_IAM_SERVICE_ACCOUNT"
}

resource "google_compute_firewall" "allow-mysql" {
  name    = "fw-allow-mysql"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }

  target_tags = ["mysql"]
}