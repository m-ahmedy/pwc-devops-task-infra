variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

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

variable "sku" {
  type        = string
  description = "ACR SKU: Basic, Standard, Premium"
}
