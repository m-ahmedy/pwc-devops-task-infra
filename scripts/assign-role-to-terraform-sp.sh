#!/bin/bash

set -e

TERRAFORM_SP_ID=$(az ad sp list --display-name=terraform-sp --query "[].id" --output tsv)

read -p "Enter the Resource Manager (Storage Container) resource ID: " RESOURCE_ID

az role assignment create \
    --assignee $TERRAFORM_SP_ID \
    --scope $RESOURCE_ID
    --role "Storage Blob Data Contributor"

read -p "Enter the Resource Manager (ACR Resource Group) resource ID: " RESOURCE_ID

az role assignment create \
  --assignee $TERRAFORM_SP_ID \
  --role "User Access Administrator" \
  --scope $RESOURCE_ID
