#!/bin/bash

set -e

read -p "Enter the service principal display name: " SP_NAME

TERRAFORM_SP_ID=$(az ad sp list --display-name=$SP_NAME --query "[].id" --output tsv)

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
