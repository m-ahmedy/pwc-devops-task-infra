
data "azurerm_container_registry" "acr" {
    name = var.registry_config.name
    resource_group_name = var.registry_config.resource_group_name
}
