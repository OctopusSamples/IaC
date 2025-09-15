terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
#      version = "4.20.0"
      version = ">= 7.2.0"
    }
  }

  backend "s3" { }
}

provider "google" {
  project = var.octopus_gcp_project
  region  = var.octopus_gcp_region
  zone    = var.octopus_gcp_zone
}