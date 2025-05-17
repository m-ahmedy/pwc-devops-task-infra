
output "storage_container_resource_manager_id" {
    description = "The id of the storage account"
    value       = azurerm_storage_container.tf_state.resource_manager_id
}

output "storage_account_name" {
    value = azurerm_storage_account.tf_backend.name
}

output "container_name" {
    value = azurerm_storage_container.tf_state.name
}

