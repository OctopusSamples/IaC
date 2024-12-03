terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      #version = ">= 2.93.1" # example: 0.7.62
      version = ">=3.7.0"
    }
  }

  backend "s3" { }
  required_version = "~> 1.9.8"
}

provider "azurerm" {
    features {}
}

resource "azurerm_resource_group" "permanent" {
    name                = var.azure_resource_group_name
    location            = var.azure_resource_group_location_name

    tags = {
        LifetimeInDays = 365
    }
}