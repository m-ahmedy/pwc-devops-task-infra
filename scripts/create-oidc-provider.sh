#!/bin/bash

set -e

read -p "Enter GitHub repository owner: " OWNER
read -p "Enter GitHub repository name: " REPO
read -p "Enter Azure service principal name: " SP_NAME

appId=$(az ad sp list --display-name "$SP_NAME" --query '[0].appId' -o tsv)

if [ -z "$appId" ]; then
    echo "Failed to retrieve appId for service principal: $SP_NAME"
    exit 1
fi

az ad app federated-credential create --id $appId \
  --parameters '{
    "name": "github-oidc",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:'"$OWNER/$REPO"':ref:refs/heads/*",
    "audiences": ["api://AzureADTokenExchange"]
  }'
