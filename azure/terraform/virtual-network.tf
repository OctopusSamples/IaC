resource "azurerm_virtual_network" "permanent" {
    name                            = format("%s_VNET", azurerm_resource_group.permanent.name)
    resource_group_name             = azurerm_resource_group.permanent.name
    location                        = azurerm_resource_group.permanent.location
    address_space                   = var.azure_virtual_network_address_space

    tags = {
        LifetimeInDays              = 365
    }
}

resource "azurerm_subnet" "default" {
    name                            = "default"
    resource_group_name             = azurerm_resource_group.permanent.name
    virtual_network_name            = azurerm_virtual_network.permanent.name
    network_security_group_name     = azurerm_network_security_group.permanent.name
    address_prefixes                = var.azure_virtual_network_address_space_default_subnet
    service_endpoints               = ["Microsoft.AzureCosmosDB", "Microsoft.KeyVault", "Microsoft.Sql", "Microsoft.Storage", "Microsoft.Web"]
}

resource "azurerm_subnet" "acs" {
    name                            = "acs"
    resource_group_name             = azurerm_resource_group.permanent.name
    virtual_network_name            = azurerm_virtual_network.permanent.name
    network_security_group_name     = azurerm_network_security_group.permanent.name
    address_prefixes                = var.azure_virtual_network_address_space_acs_subnet 

    delegation {
        name = "delegation"

        service_delegation {
        name    = "Microsoft.ContainerInstance/containerGroups"
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
        }
    }
}