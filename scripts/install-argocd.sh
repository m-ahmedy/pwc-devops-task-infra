#!/bin/bash

NAMESPACE=argocd

kubectl create namespace $NAMESPACE
kubectl apply -n $NAMESPACE -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo
echo "ArgoCD installation initiated in namespace '$NAMESPACE'."
echo "To access the ArgoCD UI, expose the service or use port-forwarding:"
echo "  kubectl port-forward svc/argocd-server -n $NAMESPACE 8080:443"

echo
echo "To get the initial admin secret of ArgoCD:"
echo "  kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d && echo"
