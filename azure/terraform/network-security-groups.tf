resource "azurerm_network_security_group" "permanent" {
    name                        = var.azure_network_security_group_name
    resource_group_name         = azurerm_resource_group.permanent.name
    location                    = azurerm_resource_group.permanent.location

    tags = {
        LifetimeInDays          = 365
    }
}

resource "azurerm_network_security_rule" "octopus" {
    name                        = "Octopus_Tentacle"
    priority                    = 100
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"        
    source_port_range           = "*"
    destination_port_range      = "10933"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = azurerm_resource_group.permanent.name
    network_security_group_name = azurerm_network_security_group.permanent.name
}

resource "azurerm_network_security_rule" "webserver_secure" {
    name                        = "Secure_Web_Traffic"
    priority                    = 200
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"        
    source_port_range           = "*"
    destination_port_range      = "443"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = azurerm_resource_group.permanent.name
    network_security_group_name = azurerm_network_security_group.permanent.name
}

resource "azurerm_network_security_rule" "webserver" {
    name                        = "Webserver"
    priority                    = 300
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"        
    source_port_range           = "*"
    destination_port_range      = "8080"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = azurerm_resource_group.permanent.name
    network_security_group_name = azurerm_network_security_group.permanent.name
}

resource "azurerm_network_security_rule" "webserver_secondary" {
    name                        = "Webserver_secondary"
    priority                    = 400
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"        
    source_port_range           = "*"
    destination_port_range      = "8090"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = azurerm_resource_group.permanent.name
    network_security_group_name = azurerm_network_security_group.permanent.name
}

resource "azurerm_network_security_rule" "webserver_thirdly" {
    name                        = "Webserver_thirdly"
    priority                    = 500
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"        
    source_port_range           = "*"
    destination_port_range      = "8088"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = azurerm_resource_group.permanent.name
    network_security_group_name = azurerm_network_security_group.permanent.name
}