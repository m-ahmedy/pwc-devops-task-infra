#!/bin/bash

set -e

# Get Terraform state outputs
BOOTSTRAP_TFSTATE_FILE="../terraform/bootstrap/terraform.tfstate"
SP_FILE="terraform-sp.json"

if [ -f "$BOOTSTRAP_TFSTATE_FILE" ]; then
  RESOURCE_ID=$(jq -r '.outputs.storage_container_resource_manager_id.value' "$BOOTSTRAP_TFSTATE_FILE")
else
  read -p "Enter the resource ID of the backend storage container: " RESOURCE_ID
fi

if [ -f "$SP_FILE" ]; then
  TERRAFORM_SP_ID=$(jq -r '.appId' "$SP_FILE")
else
  read -p "Enter the Terraform Service Principal ID: " TERRAFORM_SP_ID
fi

# Assign role
az role assignment create \
  --assignee "$TERRAFORM_SP_ID" \
  --scope "$RESOURCE_ID" \
  --role "Storage Blob Data Contributor"

echo "Role assignment successful."
