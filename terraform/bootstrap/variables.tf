
variable "storage_account_name" {
  type        = string
  description = "The storage account name"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "environments" {
  type = set(string)
  description = "Environments"
}

variable "infra_repo_owner" {
  type        = string
  description = "The owner name of the infra repo"
}

variable "infra_repo_name" {
  type        = string
  description = "The name of the infra repo"
}
