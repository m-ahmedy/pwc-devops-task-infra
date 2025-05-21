#!/bin/bash
set -e

echo "Terraform Bootstrap Script"
echo "This script will:"
echo "  1. Change to the terraform/bootstrap directory"
echo "  2. Initialize Terraform"
echo "  3. Plan and apply the Terraform configuration"
echo

pushd ../terraform/bootstrap

echo "Initializing Terraform..."
terraform init

echo "Planning Terraform changes..."
terraform plan -var-file=terraform.tfvars -out=bootstrap-plan

echo "Applying Terraform configuration..."
terraform apply -var-file=terraform.tfvars bootstrap-plan

echo
echo "Bootstrap complete!"
echo "Please use the outputs to set the rest of the configurations up."

popd
