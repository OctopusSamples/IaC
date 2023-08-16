resource "azurerm_container_registry" "acr" {
  name                = "Samples"
  resource_group_name = azurerm_resource_group.permanent.name
  location            = azurerm_resource_group.permanent.location
  sku                 = "Basic"
  admin_enabled       = false
}