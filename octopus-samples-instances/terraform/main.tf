terraform {
  required_providers {
    octopusdeploy = {
      source = "OctopusDeployLabs/octopusdeploy"
      version = "0.7.63" # example: 0.7.62
    }
  }

  backend "s3" {
    bucket = "#{Project.AWS.Backend.Bucket}"
    key = "#{Project.AWS.Backend.Key}"
    region = "#{Project.AWS.Backend.Region}"
  }
}

provider "octopusdeploy" {
  # configuration options
  address    = var.octopus_address
  api_key    = var.octopus_api_key
  space_id   = var.octopus_space_id
}

resource "octopusdeploy_feed" "github" {
  name = "GitHub TF Feed"
  feed_type = "GitHub"
  feed_uri = "https://api.github.com"
  password = var.octopus_github_password
}

resource "octopusdeploy_feed" "feedz" {
  name = "Feedz TF Feed"
  feed_type = "NuGet"
  feed_uri = "https://f.feedz.io/octopus-deploy-samples/shared-repo"
  password = var.octopus_feedz_password
  username = var.octopus_feedz_username
}