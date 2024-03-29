terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.93.1" # example: 0.7.62
    }
  }

  backend "s3" { }
}

provider "azurerm" {
    features {}
}

variable "azure_us_central_resource_group_name" {
    type = string
}

variable "azure_us_central_virtual_network_name" {
    type = string
}

variable "azure_us_east_resource_group_name" {
    type = string
}

variable "azure_us_east_virtual_network_name" {
    type = string
}

variable "azure_uk_south_resource_group_name" {
    type = string
}

variable "azure_uk_south_virtual_network_name" {
    type = string
}

variable "azure_uk_west_resource_group_name" {
    type = string
}

variable "azure_uk_west_virtual_network_name" {
    type = string
}

data "azurerm_virtual_network" "us_central" {
    name                            = var.azure_us_central_virtual_network_name
    resource_group_name             = var.azure_us_central_resource_group_name
}

data "azurerm_virtual_network" "us_east" {
    name                            = var.azure_us_east_virtual_network_name
    resource_group_name             = var.azure_us_east_resource_group_name
}

data "azurerm_virtual_network" "uk_south" {
    name                            = var.azure_uk_south_virtual_network_name
    resource_group_name             = var.azure_uk_south_resource_group_name
}

data "azurerm_virtual_network" "uk_west" {
    name                            = var.azure_uk_west_virtual_network_name
    resource_group_name             = var.azure_uk_west_resource_group_name
}

resource "azurerm_virtual_network_peering" "us_central_us_east" {
    name                            = "peering-us-central-to-us-east"
    resource_group_name             = var.azure_us_central_resource_group_name
    virtual_network_name            = var.azure_us_central_virtual_network_name
    remote_virtual_network_id       = data.azurerm_virtual_network.us_east.id
    allow_virtual_network_access    = true
    allow_forwarded_traffic         = true
    allow_gateway_transit           = false
}

resource "azurerm_virtual_network_peering" "us_east_us_central" {
    name                            = "peering-us-east-to-us-central"
    resource_group_name             = var.azure_us_east_resource_group_name
    virtual_network_name            = var.azure_us_east_virtual_network_name
    remote_virtual_network_id       = data.azurerm_virtual_network.us_central.id
    allow_virtual_network_access    = true
    allow_forwarded_traffic         = true
    allow_gateway_transit           = false
}

resource "azurerm_virtual_network_peering" "us_central_uk_south" {
    name                            = "peering-us-central-to-uk-south"
    resource_group_name             = var.azure_us_central_resource_group_name
    virtual_network_name            = var.azure_us_central_virtual_network_name
    remote_virtual_network_id       = data.azurerm_virtual_network.uk_south.id
    allow_virtual_network_access    = true
    allow_forwarded_traffic         = true
    allow_gateway_transit           = false
}

resource "azurerm_virtual_network_peering" "uk_south_us_central" {
    name                            = "peering-uk-south-to-us-central"
    resource_group_name             = var.azure_uk_south_resource_group_name
    virtual_network_name            = var.azure_uk_south_virtual_network_name
    remote_virtual_network_id       = data.azurerm_virtual_network.us_central.id
    allow_virtual_network_access    = true
    allow_forwarded_traffic         = true
    allow_gateway_transit           = false
}

resource "azurerm_virtual_network_peering" "us_central_uk_west" {
    name                            = "peering-us-central-to-uk-west"
    resource_group_name             = var.azure_us_central_resource_group_name
    virtual_network_name            = var.azure_us_central_virtual_network_name
    remote_virtual_network_id       = data.azurerm_virtual_network.uk_west.id
    allow_virtual_network_access    = true
    allow_forwarded_traffic         = true
    allow_gateway_transit           = false
}

resource "azurerm_virtual_network_peering" "uk_west_us_central" {
    name                            = "peering-uk-west-to-us-central"
    resource_group_name             = var.azure_uk_west_resource_group_name
    virtual_network_name            = var.azure_uk_west_virtual_network_name
    remote_virtual_network_id       = data.azurerm_virtual_network.us_central.id
    allow_virtual_network_access    = true
    allow_forwarded_traffic         = true
    allow_gateway_transit           = false
}

resource "azurerm_virtual_network_peering" "us_east_uk_south" {
    name                            = "peering-us-east-to-uk-south"
    resource_group_name             = var.azure_us_east_resource_group_name
    virtual_network_name            = var.azure_us_east_virtual_network_name
    remote_virtual_network_id       = data.azurerm_virtual_network.uk_south.id
    allow_virtual_network_access    = true
    allow_forwarded_traffic         = true
    allow_gateway_transit           = false
}

resource "azurerm_virtual_network_peering" "uk_south_us_east" {
    name                            = "peering-uk-south-to-us-east"
    resource_group_name             = var.azure_uk_south_resource_group_name
    virtual_network_name            = var.azure_uk_south_virtual_network_name
    remote_virtual_network_id       = data.azurerm_virtual_network.us_east.id
    allow_virtual_network_access    = true
    allow_forwarded_traffic         = true
    allow_gateway_transit           = false
}

resource "azurerm_virtual_network_peering" "us_east_uk_west" {
    name                            = "peering-us-east-to-uk-west"
    resource_group_name             = var.azure_us_east_resource_group_name
    virtual_network_name            = var.azure_us_east_virtual_network_name
    remote_virtual_network_id       = data.azurerm_virtual_network.uk_west.id
    allow_virtual_network_access    = true
    allow_forwarded_traffic         = true
    allow_gateway_transit           = false
}

resource "azurerm_virtual_network_peering" "uk_west_us_east" {
    name                            = "peering-uk-west-to-us-east"
    resource_group_name             = var.azure_uk_west_resource_group_name
    virtual_network_name            = var.azure_uk_west_virtual_network_name
    remote_virtual_network_id       = data.azurerm_virtual_network.us_east.id
    allow_virtual_network_access    = true
    allow_forwarded_traffic         = true
    allow_gateway_transit           = false
}

resource "azurerm_virtual_network_peering" "uk_south_uk_west" {
    name                            = "peering-uk-south-to-uk-west"
    resource_group_name             = var.azure_uk_south_resource_group_name
    virtual_network_name            = var.azure_uk_south_virtual_network_name
    remote_virtual_network_id       = data.azurerm_virtual_network.uk_west.id
    allow_virtual_network_access    = true
    allow_forwarded_traffic         = true
    allow_gateway_transit           = false
}

resource "azurerm_virtual_network_peering" "uk_west_uk_south" {
    name                            = "peering-uk-west-to-uk-south"
    resource_group_name             = var.azure_uk_west_resource_group_name
    virtual_network_name            = var.azure_uk_west_virtual_network_name
    remote_virtual_network_id       = data.azurerm_virtual_network.uk_south.id
    allow_virtual_network_access    = true
    allow_forwarded_traffic         = true
    allow_gateway_transit           = false
}