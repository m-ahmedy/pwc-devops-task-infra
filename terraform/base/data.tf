
data "azurerm_container_registry" "acr" {
  depends_on = [ module.aks_cluster, module.container_registry ]

  name                = var.registry_name
  resource_group_name = var.registry_resource_group_name
}
