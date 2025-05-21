
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.29.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "=3.4.0"
    }
  }
}

# Providers
provider "azurerm" {
  features {}
}
provider "azuread" {}

# Terraform Service Principal
resource "azuread_application" "tf_sp" {
  display_name = "tf-service-principal"
}

resource "azuread_service_principal" "tf_sp" {
  client_id = azuread_application.tf_sp.client_id
}

## Azure Backend
resource "azurerm_resource_group" "tf_backend" {
    name     = var.resource_group_name
    location = var.location
}

resource "azurerm_storage_account" "tf_backend" {
    name                     = var.storage_account_name
    resource_group_name      = azurerm_resource_group.tf_backend.name
    location                 = azurerm_resource_group.tf_backend.location
    account_tier             = "Standard"
    account_replication_type = "LRS"
}

resource "azurerm_storage_container" "tf_state" {
    name                  = "tfstate"
    storage_account_name  = azurerm_storage_account.tf_backend.name
    container_access_type = "private"
}

# Resource Groups for environments
resource "azurerm_resource_group" "environment_rg" {
  for_each = var.environments
  name = format("pwc-%s-rg", each.value)
  location = var.location
}

# Federated Credentials
resource "azuread_application_federated_identity_credential" "tf_sp_github" {
  for_each = var.environments

  application_id = azuread_application.tf_sp.id
  display_name          = format("github-actions-%s", each.value)
  description           = format("Federated credential for GitHub Actions - %s Environment", each.value)
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = "https://token.actions.githubusercontent.com"
  subject               = format("repo:%s:environment:%s", local.repo, each.value)
}

# Role Assignments

resource "azurerm_role_assignment" "contributor" {
  for_each = azurerm_resource_group.environment_rg

  scope                = each.value.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.tf_sp.object_id
}

resource "azurerm_role_assignment" "tf_backend_contributor" {
  scope                = azurerm_resource_group.tf_backend.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.tf_sp.object_id
}

resource "azurerm_role_assignment" "user_access_admin" {
  for_each = azurerm_resource_group.environment_rg

  scope                = each.value.id
  role_definition_name = "User Access Administrator"
  principal_id         = azuread_service_principal.tf_sp.object_id
}

resource "azurerm_role_assignment" "data_blob_access" {
  scope                = azurerm_storage_container.tf_state.resource_manager_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.tf_sp.object_id
}
