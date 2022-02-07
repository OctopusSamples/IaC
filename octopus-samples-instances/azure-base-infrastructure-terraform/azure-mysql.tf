resource "azurerm_mysql_server" "permanent" {
    name                             = var.azure_mysql_name
    resource_group_name              = azurerm_resource_group.permanent.name
    location                         = azurerm_resource_group.permanent.location
    
    administrator_login              = var.azure_mysql_administrator_name
    administrator_login_password     = var.azure_mysql_administrator_password

    sku_name                         = "B_Gen5_1"
    version                          = "5.7"
    storage_mb                       = 5120
    backup_retention_days            = 7
    geo_redundant_backup_enabled     = false
    auto_grow_enabled                = false
    public_network_access_enabled    = false
    ssl_enforcement_enabled          = true
    ssl_minimal_tls_version_enforced = "TLS1_2"
}