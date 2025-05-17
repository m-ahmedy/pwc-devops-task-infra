
variable "location" {
  type        = string
  description = "Azure region"
}

variable "environment" {
  type        = string
  description = "Deployment environment name: dev, prod"
}

variable "registry_name" {
  type        = string
  description = "Globally unique name for the ACR"
}

variable "registry_sku" {
  type        = string
  description = "ACR SKU: Basic, Standard, Premium"
}

variable "registry_resource_group_name" {
  type        = string
  description = "The name of the resource group of the registry"
}

variable "cluster_resource_group_name" {
  type        = string
  description = "The name of the resource group of the cluster"
}

variable "cluster_name" {
  type        = string
  description = "Name of the AKS cluster"
}

variable "cluster_dns_prefix" {
  type        = string
  description = "DNS prefix for AKS"
}

variable "cluster_node_count" {
  type        = number
  description = "Number of nodes in default node pool"
}

variable "cluster_vm_size" {
  type        = string
  description = "VM size for AKS nodes"
}
