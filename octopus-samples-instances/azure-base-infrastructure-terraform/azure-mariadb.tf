resource "azurerm_mariadb_server" "permanent" {
  name                = var.azure_mariadb_name
  resource_group_name = azurerm_resource_group.permanent.name
  location            = azurerm_resource_group.permanent.location

  administrator_login    = var.azure_mariadb_administrator_name
  administrator_login_password = var.azure_mariadb_administrator_password

  sku_name                     = "B_Gen5_1"
  version                      = "10.4"
  backup_retention_days        = 1
  geo_redundant_backup_enabled = false
  ssl_enforcement_enabled = true
  storage_mb = 5120

  tags = {
    LifetimeInDays = 365
  }
}

resource "azurerm_mariadb_firewall_rule" "all_azure_resources" {
  name                = "all-azure-resources"
  resource_group_name = azurerm_resource_group.permanent.name
  server_name         = azurerm_mysql_flexible_server.permanent.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}