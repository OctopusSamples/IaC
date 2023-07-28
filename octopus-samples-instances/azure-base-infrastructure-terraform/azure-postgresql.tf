resource "azurerm_postgresql_flexible_server" "permanent" {
  name                = var.azure_postresql_name
  resource_group_name = azurerm_resource_group.permanent.name
  location            = azurerm_resource_group.permanent.location

  administrator_login    = var.azure_postgresql_administrator_name
  administrator_password = var.azure_postgresql_administrator_password

  sku_name                     = "B_Standard_B1ms"
  version                      = "11"
  storage_mb                   = 32768
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  tags = {
    LifetimeInDays = 365
  }
  
  authentication {
    active_directory_auth_enabled = true
    password_auth_enabled = true
  }
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "all_azure_resources" {
  name      = "all-azure-resources"
  server_id = azurerm_postgresql_flexible_server.permanent.id

  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}
