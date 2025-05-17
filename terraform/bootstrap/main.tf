
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}

provider "azurerm" {
  features {}
}

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
