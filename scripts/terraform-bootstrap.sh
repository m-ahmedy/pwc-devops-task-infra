#!/bin/bash
set -e

echo "Terraform Bootstrap Script"
echo "This script will:"
echo "  1. Change to the terraform/bootstrap directory"
echo "  2. Initialize Terraform"
echo "  3. Plan and apply the Terraform configuration"
echo "  4. Output the storage_container_id for use in the next step"
echo

pushd ../terraform/bootstrap

echo "Initializing Terraform..."
terraform init

echo "Planning Terraform changes..."
terraform plan -var-file=terraform.tfvars

echo "Applying Terraform configuration..."
terraform apply -var-file=terraform.tfvars

echo "Extracting storage_container_id from terraform.tfstate..."
storage_container_id=$(cat terraform.tfstate | jq -r '.outputs.storage_container_resource_manager_id.value')

echo
echo "Bootstrap complete!"
echo "Please use the following storage_container_id in your next script assign-storage-role-terraform-sp:"
echo "$storage_container_id"

popd
