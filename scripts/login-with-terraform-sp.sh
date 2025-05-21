#!/bin/bash

# Path to the service principal credentials file
CREDENTIALS_FILE="terraform-sp.json"

echo "Azure Service Principal Login Script"
echo "--------------------------------------"

if [[ ! -f "$CREDENTIALS_FILE" ]]; then
    echo "Credentials file '$CREDENTIALS_FILE' not found in $(pwd)."
    echo "Please make sure the file exists and try again."
    exit 1
fi

APP_ID=$(jq -r .clientId "$CREDENTIALS_FILE")
PASSWORD=$(jq -r .clientSecret "$CREDENTIALS_FILE")
TENANT=$(jq -r .tenantId "$CREDENTIALS_FILE")

if [[ -z "$APP_ID" || -z "$PASSWORD" || -z "$TENANT" ]]; then
    echo "Missing required fields in credentials file."
    echo "Please check that 'clientId', 'clientSecret', and 'tenantId' are present."
    exit 1
fi

echo "Credentials loaded. Attempting to log in to Azure..."

if az login --service-principal -u "$APP_ID" -p "$PASSWORD" --tenant "$TENANT" >/dev/null 2>&1; then
    echo "Successfully logged in as Service Principal: $APP_ID"
else
    echo "Azure login failed. Please check your credentials and network connection."
    exit 1
fi
