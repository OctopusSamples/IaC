resource "azurerm_storage_account" "permanent" {
    name                            = format("sql%s", replace(var.azure_sql_name, "-", ""))
    resource_group_name             = azurerm_resource_group.permanent.name
    location                        = azurerm_resource_group.permanent.location
    account_tier                    = "Standard"
    account_replication_type        = "LRS"

    tags = {
        LifetimeInDays = 365
    }
}

resource "azurerm_mssql_server" "permanent" {
    name                            = var.azure_sql_name
    resource_group_name             = azurerm_resource_group.permanent.name
    location                        = azurerm_resource_group.permanent.location
    version                         = "12.0"
    administrator_login             = var.azure_sql_administrator_name
    administrator_login_password    = var.azure_sql_administrator_password
    minimum_tls_version             = "1.2"
    public_network_access_enabled   = true

    tags = {
        LifetimeInDays = 365
    }
}

resource "azurerm_mssql_virtual_network_rule" "permanent" {
    name                            = format("%s-vnet-rule", var.azure_sql_name)
    server_id                       = azurerm_mssql_server.permanent.id
    subnet_id                       = azurerm_subnet.default.id
}