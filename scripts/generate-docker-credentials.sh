#!/bin/bash

set -e

read -p "Enter the ACR name: " ACR_NAME
read -p "Enter token name: " TOKEN_NAME

response=$(az acr token credential generate \
  --name $TOKEN_NAME \
  --registry $ACR_NAME \
  --output json)

echo $response > acr-token-credentials.json

username=$(echo $response | jq -r ".username")
password=$(echo $response | jq -r ".passwords[0].value")
acr_login_server=$ACR_NAME.azurecr.io

echo "In your GitHub repository, go to Settings > Secrets and variables > Actions."

echo "Add a new variable named 'ACR_USERNAME' with the username value: $username"
echo "Add a new variable named 'ACR_LOGIN_SERVER' with the server value: $acr_login_server"
echo "Add a new secret named 'ACR_PASSWORD' with the password value: $password"

echo
echo "To sign in to your ACR locally using Docker, run the following command:"
echo "echo $password | docker login $acr_login_server -u $username --password-stdin"
