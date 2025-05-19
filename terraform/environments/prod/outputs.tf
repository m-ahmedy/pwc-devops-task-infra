
output "aks_cluster_outputs" {
    value = module.aks_cluster
}

output "container_registry_outputs" {
    value = data.azurerm_container_registry.acr.login_server
}

output "acr_cluster_binding_token_name" {
    value = module.acr_cluster_bindings.token_name
}
