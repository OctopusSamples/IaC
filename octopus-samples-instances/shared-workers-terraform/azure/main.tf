terraform {

  required_version = ">=0.12"
  
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
#      version = "~>2.0"
#      version = ">=3.0"
      version = ">=2.99"
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
