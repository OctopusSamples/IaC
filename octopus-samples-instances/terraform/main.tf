terraform {
  required_providers {
    octopusdeploy = {
      source = "OctopusDeployLabs/octopusdeploy"
      version = "0.7.63" # example: 0.7.62
    }
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
  username = var.octopus_github_username
  password = var.octopus_github_password
}