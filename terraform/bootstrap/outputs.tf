
output "tf_backend_resource_group" {
  value = azurerm_storage_account.tf_backend.resource_group_name
}

output "tf_backend_storage_account_name" {
  value = azurerm_storage_account.tf_backend.name
}

output "tf_backend_storage_container_name" {
  value = azurerm_storage_container.tf_state.name
}

output "environments_resource_group_names" {
  value = [for rg in azurerm_resource_group.environment_rg : rg.name]
}

output "terraform_sp_client_id" {
    value = azuread_service_principal.tf_sp.client_id
}

output "terraform_sp_subscription_id" {
    value = data.azurerm_client_config.current.subscription_id
}

output "terraform_sp_tenant_id" {
    value = data.azurerm_client_config.current.tenant_id
}
