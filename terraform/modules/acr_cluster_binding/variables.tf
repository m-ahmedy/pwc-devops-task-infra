
variable "environment" {
  type = string
  description = "Environment for which token will be created"
}

variable "cluster_object_id" {
  type        = string
  description = "AKS cluster object ID"
}

variable "acr_name" {
  type        = string
  description = "Name of the Azure Container Registry"
}

variable "acr_id" {
  type        = string
  description = "ID of the Azure Container Registry"
}

variable "acr_registry_group" {
  type        = string
  description = "Name of the Azure Container Registry Resource Group"
}

