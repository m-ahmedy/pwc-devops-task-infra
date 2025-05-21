#!/bin/bash

set -e

echo "This script sets up a federated credential (OIDC provider) in Azure AD for a GitHub repository and environment."
echo "It prompts for or uses environment variables for the repository owner, name, environment, and Azure service principal name."
echo "The script retrieves the service principal's appId and creates a federated credential for GitHub Actions OIDC authentication."
echo

# Get OWNER from env or prompt
if [ -z "$OWNER" ]; then
  read -p "Enter GitHub repository owner: " OWNER
fi

# Get REPO from env or prompt
if [ -z "$REPO" ]; then
  read -p "Enter GitHub repository name: " REPO
fi

# Get ENVIRONMENT from env or prompt
if [ -z "$ENVIRONMENT" ]; then
  read -p "Enter GitHub repository environment: " ENVIRONMENT
fi

# Get SP_NAME from env or prompt
if [ -z "$SP_NAME" ]; then
  read -p "Enter Azure service principal name: " SP_NAME
fi

appId=$(az ad sp list --display-name "$SP_NAME" --query '[0].appId' -o tsv)

if [ -z "$appId" ]; then
    echo "Failed to retrieve appId for service principal: $SP_NAME"
    exit 1
fi

az ad app federated-credential create --id $appId \
  --parameters '{
    "name": "github-oidc-'"$ENVIRONMENT"'",
    "issuer": "https://token.actions.githubusercontent.com",
    "subjectRegex": "repo:'"$OWNER/$REPO"':environment:'"$ENVIRONMENT"'",
    "audiences": ["api://AzureADTokenExchange"]
  }'

echo "Federated credential 'github-oidc' has been created for service principal '$SP_NAME' (AppId: $appId)."
echo "OIDC provider setup is complete for repository '$OWNER/$REPO' and environment '$ENVIRONMENT'."
