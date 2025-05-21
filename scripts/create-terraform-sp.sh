#!/bin/bash

set -e

echo "This script creates an Azure Service Principal for Terraform."
echo "Usage: $0 <ARM_SUBSCRIPTION_ID>"
echo "To get your all subscriptions on the account, run:"
echo "  az account list --output table"
echo
echo "To set your subscription ID, run:"
echo "  export ARM_SUBSCRIPTION_ID=\$(az account list --output tsv --query \"[<subscription-number>].id\")"
echo

if [ -z "$ARM_SUBSCRIPTION_ID" ]; then
    echo "Error: Subscription ID not provided."
    echo "Usage: $0 <SUBSCRIPTION_ID>"
    echo "Get it from 'az account list'"
    exit 1
fi

echo "Creating Service Principal 'terraform-sp' with Contributor role for subscription: $ARM_SUBSCRIPTION_ID"
echo

az ad sp create-for-rbac \
    --name "terraform-sp" \
    --role="Contributor" \
    --years 2 \
    --scopes="/subscriptions/$ARM_SUBSCRIPTION_ID" > terraform-sp.json

terraform_sp_id=$(cat terraform-sp.json | jq -r '.clientId')

az role assignment create \
  --assignee "$terraform_sp_id" \
  --scope "/subscriptions/$ARM_SUBSCRIPTION_ID" \
  --role "User Access Administrator"

echo "Service Principal created. Credentials saved to terraform-sp.json:"
cat terraform-sp.json
