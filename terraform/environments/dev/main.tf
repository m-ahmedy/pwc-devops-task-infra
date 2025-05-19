
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.29.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "aks_cluster" {
  source      = "../../modules/aks"
  location    = var.location
  environment = var.environment

  resource_group_name = var.cluster_config.resource_group_name
  cluster_name        = var.cluster_config.name
  dns_prefix          = var.cluster_config.dns_prefix
  node_count          = var.cluster_config.node_count
  vm_size             = var.cluster_config.vm_size
}

module "container_registry" {
  source      = "../../modules/acr"
  location    = var.location
  environment = var.environment

  resource_group_name = var.registry_config.resource_group_name
  sku                 = var.registry_config.sku
  registry_name       = var.registry_config.name
}

module "acr_cluster_bindings" {
  source     = "../../modules/acr_cluster_binding"
  depends_on = [local.acr, module.aks_cluster]

  acr_name           = local.acr.name
  acr_id             = local.acr.id
  acr_registry_group = local.acr.resource_group_name

  environment       = var.environment
  cluster_object_id = module.aks_cluster.object_id
}
