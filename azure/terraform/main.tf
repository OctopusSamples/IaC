terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.93.1" # example: 0.7.62
    }
  }

  backend "s3" {
    bucket = "#{Project.AWS.Backend.Bucket}"
    key = "#{Project.AWS.Backend.Key}"
    region = "#{Project.AWS.Backend.Region}"
  }
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