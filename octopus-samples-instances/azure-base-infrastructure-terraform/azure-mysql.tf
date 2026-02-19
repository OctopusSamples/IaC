resource "azurerm_mysql_flexible_server" "permanent" {
  name                = var.azure_mysql_name
  resource_group_name = azurerm_resource_group.permanent.name
  location            = azurerm_resource_group.permanent.location
  public_network_access_enabled = true
  administrator_login    = var.azure_mysql_administrator_name
  administrator_password = var.azure_mysql_administrator_password

  sku_name                     = "B_Standard_B1ms"
  version                      = "8.0.21"
  backup_retention_days        = 1
  geo_redundant_backup_enabled = false

  storage {
    auto_grow_enabled = false
    size_gb           = 20
  }

  tags = {
    LifetimeInDays = 365
  }
}

resource "azurerm_mysql_flexible_server_firewall_rule" "all_azure_resources" {
  name                = "all-azure-resources"
  resource_group_name = azurerm_resource_group.permanent.name
  server_name         = azurerm_mysql_flexible_server.permanent.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_mysql_flexible_server_configuration" "log_bin_trust_function_creators" {
  name                = "log_bin_trust_function_creators"
  resource_group_name = azurerm_resource_group.permanent.name
  server_name         = azurerm_mysql_flexible_server.permanent.name
  value               = "ON"
}
