
resource "azurerm_resource_group" "registry_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_container_registry" "acr" {
  name                = var.registry_name
  resource_group_name = azurerm_resource_group.registry_rg.name
  location            = azurerm_resource_group.registry_rg.location
  sku                 = var.sku
  admin_enabled       = true
}
