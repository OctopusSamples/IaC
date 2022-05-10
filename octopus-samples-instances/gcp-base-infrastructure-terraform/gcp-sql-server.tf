resource "google_sql_database_instance" "mssql" {
  database_version = var.mssql_version
  region = var.octopus_gcp_region
  root_password = var.mysql_admin_password
  deletion_protection = false

  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = "db-custom-1-3840"
  }
}

resource "google_compute_firewall" "allow-mssql" {
  name    = "fw-allow-mssql"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["1433"]
  }

  target_tags = ["mssql"]
}