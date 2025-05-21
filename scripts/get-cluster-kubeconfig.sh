#!/bin/bash

set -e

read -p "Enter the Resource Manager (AKS Cluster Resource Group) name: " CLUSTER_RG_NAME
read -p "Enter the AKS cluster name: " CLUSTER_NAME
read -p "Enter the kubeconfig output file: " KUBECONFIG_OUT_FILE

if [[ -z "$KUBECONFIG_OUT_FILE" ]]; then
    KUBECONFIG_OUT_FILE="$HOME/.kube/config"
fi

az aks get-credentials \
    --resource-group $CLUSTER_RG_NAME \
    --name $CLUSTER_NAME \
    --file $KUBECONFIG_OUT_FILE
