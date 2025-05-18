#!/bin/bash

set -e

SUBSCRIPTION_ID=${1:-$ARM_SUBSCRIPTION_ID}

if [ -z "$SUBSCRIPTION_ID" ]; then
    echo "Usage: $0 <SUBSCRIPTION_ID>"
    echo "Get it from 'az account subscription list'"
    exit 1
fi

az ad sp create-for-rbac \
    --name "terraform-sp" \
    --role="Contributor" \
    --years 2 \
    --scopes="/subscriptions/$SUBSCRIPTION_ID" > terraform-sp.json

cat terraform-sp.json
