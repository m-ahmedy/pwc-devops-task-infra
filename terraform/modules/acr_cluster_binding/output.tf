
output "token_name" {
    description = "The name of the token used for the ACR cluster binding."
    value       = azurerm_container_registry_token.acr_rw_token.name
}
