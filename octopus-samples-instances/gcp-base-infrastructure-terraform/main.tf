terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.20.0"
    }
  }

  backend "s3" { }
  required_version = "~> 1.9.8"
}

provider "google" {
  project = var.octopus_gcp_project
  region  = var.octopus_gcp_region
  zone    = var.octopus_gcp_zone
}