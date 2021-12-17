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
  space_name = var.octopus_space_name
}

resource "octopusdeploy_environment" "test" {
    name = "Test"
}

resource "octopusdeploy_environment" "production" {
    name = "Production"
}

resource "octopusdeploy_lifecycle" "default_lifecycle" {
    name = "Default"

    release_retention_policy {
        quantity_to_keep = 5
        unit = "Days"        
    }

    tentacle_retention_policy {
        quantity_to_keep = 5
        unit = "Days"
    }
}