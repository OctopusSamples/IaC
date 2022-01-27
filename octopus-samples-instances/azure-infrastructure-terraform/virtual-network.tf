resource "azurerm_virtual_network" "permanent" {
    name                            = var.azure_virtual_network_name
    resource_group_name             = azurerm_resource_group.permanent.name
    location                        = azurerm_resource_group.permanent.location
    address_space                   = var.azure_virtual_network_address_space

    tags = {
        LifetimeInDays              = 365
    }
}

resource "azurerm_subnet" "default" {
    name                            = var.azure_virtual_network_default_subnet_name
    resource_group_name             = azurerm_resource_group.permanent.name
    virtual_network_name            = azurerm_virtual_network.permanent.name
    address_prefixes                = var.azure_virtual_network_address_space_default_subnet
    service_endpoints               = ["Microsoft.AzureCosmosDB", "Microsoft.KeyVault", "Microsoft.Sql", "Microsoft.Storage", "Microsoft.Web"]
}

resource "azurerm_subnet_network_security_group_association" "default_subnet_security_group" {
    subnet_id = azurerm_subnet.default.id
    network_security_group_id = azurerm_network_security_group.permanent.id
}

resource "azurerm_subnet" "acs" {
    name                            = var.azure_virtual_network_acs_subnet_name
    resource_group_name             = azurerm_resource_group.permanent.name
    virtual_network_name            = azurerm_virtual_network.permanent.name    
    address_prefixes                = var.azure_virtual_network_address_space_acs_subnet 

    delegation {
        name = "delegation"

        service_delegation {
        name    = "Microsoft.ContainerInstance/containerGroups"
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
        }
    }
}

resource "azurerm_subnet_network_security_group_association" "default_acs_security_group" {
    subnet_id = azurerm_subnet.acs.id
    network_security_group_id = azurerm_network_security_group.permanent.id
}