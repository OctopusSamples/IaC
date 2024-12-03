terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }

  backend "s3" {
    bucket = "#{Project.AWS.Backend.Bucket}"
    key = "#{Project.AWS.Backend.Key}"
    region = "#{Project.AWS.Backend.Region}"
  }
  
}

provider "google" {
  #credentials = file("octopus-samples-1b88d430efea.json")

  project = var.gcp_project
  region  = var.gcp_region
  zone    = var.gcp_zone
}