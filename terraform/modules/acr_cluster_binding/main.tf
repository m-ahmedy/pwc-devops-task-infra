
resource "azurerm_container_registry_scope_map" "acr_rw_scope_map" {
  name                    = format("%s-acr-scope-map", var.environment)
  container_registry_name = var.acr_name
  resource_group_name     = var.acr_registry_group
  actions = [
    "repositories/*/content/read",
    "repositories/*/content/write"
  ]
}

resource "azurerm_container_registry_token" "acr_rw_token" {
  name                    = format("%s-acr-rw-token", var.environment)
  container_registry_name = var.acr_name
  resource_group_name     = var.acr_registry_group
  scope_map_id            = azurerm_container_registry_scope_map.acr_rw_scope_map.id
}

resource "azurerm_role_assignment" "acr_role_assignments" {
  principal_id                     = var.cluster_object_id
  role_definition_name             = "AcrPull"
  scope                            = var.acr_id
  skip_service_principal_aad_check = true
}
