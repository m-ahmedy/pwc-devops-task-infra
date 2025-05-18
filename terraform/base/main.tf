
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
    count = var.environment == "dev" ? 1 : 0

    source = "../modules/acr"
    location            = var.location
    environment         = var.environment

    resource_group_name = var.registry_resource_group_name
    sku = var.registry_sku
    registry_name = var.registry_name
}

module "acr_cluster_bindings" {
  source = "../modules/acr_cluster_binding"

  acr_name = data.azurerm_container_registry.acr.name
  acr_id = data.azurerm_container_registry.acr.id
  acr_registry_group = data.azurerm_container_registry.acr.resource_group_name

  environment = var.environment
  cluster_object_id = module.aks_cluster.object_id
}
