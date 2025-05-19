
variable "location" {
  type        = string
  description = "Azure region"
}

variable "environment" {
  type        = string
  description = "Deployment environment name: dev, prod"
}

variable "registry_config" {
  type = object({
    name                = string
    sku                 = string
    resource_group_name = string
  })
  description = "Configuration for the Azure Container Registry (ACR)"
}

variable "cluster_config" {
  type = object({
    resource_group_name = string
    name               = string
    dns_prefix         = string
    node_count         = number
    vm_size            = string
  })
  description = "Configuration for the AKS cluster"
}
