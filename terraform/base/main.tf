
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

module "aks_cluster" {
    source = "../modules/aks"
    location            = var.location
    environment         = var.environment

    resource_group_name = var.cluster_resource_group_name
    cluster_name = var.cluster_name
    dns_prefix = var.cluster_dns_prefix
    node_count = var.cluster_node_count
    vm_size = var.cluster_vm_size
}

module "container_registry" {
    source = "../modules/acr"
    location            = var.location
    environment         = var.environment

    resource_group_name = var.registry_resource_group_name
    sku = var.registry_sku
    registry_name = var.registry_name
}

resource "azurerm_role_assignment" "AcrPull" {
  principal_id                     = module.aks_cluster.object_id
  role_definition_name             = "AcrPull"
  scope                            = module.container_registry.registry_id
  skip_service_principal_aad_check = true
}
