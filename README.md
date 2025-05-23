# PwC DevOps Task Infrastructure

This repository contains the infrastructure setup for the PwC DevOps Task. It includes configuration files, scripts, and instructions to provision and manage the required cloud resources using Infrastructure as Code (IaC) tools.

![](./media/dev-app-network.png)

---

## Table of Contents
1. [Directory Structure](#directory-structure)
2. [Prerequisites](#prerequisites)
3. [Repository & GitHub Setup](#repository--github-setup)
  - [Personal Access Tokens (PATs)](#personal-access-tokens-pats)
  - [Repository Variables](#repository-variables)
  - [GitHub Environments](#github-environments)
4. [Azure & Terraform Setup](#azure--terraform-setup)
  - [Login to Azure](#login-to-azure)
  - [Create Prerequisites Resources](#create-prerequisites-resources)
  - [Create Infrastructure Environments](#create-infrastructure-environments)
5. [Kubernetes & ArgoCD Setup](#kubernetes--argocd-setup)
  - [Get Cluster Kubeconfig](#get-cluster-kubeconfig)
  - [Generate ACR Tokens](#generate-acr-tokens)
  - [Run Deployment Workflow](#run-deployment-workflow)
  - [Install ArgoCD](#install-argocd)
  - [Log in to ArgoCD](#log-in-to-argocd)
  - [Import Clusters](#import-clusters)
  - [Create the App of Apps root app](#create-the-app-of-apps-root-app)
  - [Generate ArgoCD Manifests](#generate-argocd-manifests)
  - [Copy the generated application manifest to the argocd/apps directory](#copy-the-generated-application-manifest-to-the-argocdapps-directory)
  - [Access the App](#access-the-app)
6. [Final Outputs](#final-outputs)
7. [Destroy the environments](#destroy-the-environments)
8. [Potential room for improvement](#potential-room-for-improvement)

---

## Directory Structure

```
infra/
├── README.md
├── .github/
│   └── workflows/         # GitHub Actions CI/CD workflows
├── terraform/
│   ├── bootstrap/         # Terraform scripts for prerequisite resources (backend, SP, etc.)
│   └── environments/              # Environment-specific Terraform configurations (dev, prod)
├── kustomize/             # Kubernetes manifests using Kustomize
├── scripts/               # Helper scripts for automation (bootstrap, kubeconfig, ACR, ArgoCD, etc.)
└── argocd/
  ├── generator/         # Automation for generating templated ArgoCD manifests
  ├── root/              # Root App of Apps manifest
  └── apps/              # Application manifests managed by ArgoCD
├── kustomize/             # Kubernetes manifests using Kustomize
├── scripts/               # Helper scripts for automation (bootstrap, kubeconfig, ACR, ArgoCD, etc.)
└── argocd/
  ├── generator/         # Automation for generating templated ArgoCD manifests
  ├── root/              # Root App of Apps manifest
  └── apps/              # Application manifests managed by ArgoCD
```

---

## Prerequisites

Ensure you have the following tools installed:

- [Git](https://git-scm.com/)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Terraform](https://www.terraform.io/downloads.html)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [ArgoCD CLI](https://argo-cd.readthedocs.io/en/stable/cli_installation/)
- [Docker](https://docs.docker.com/get-docker/) (optional)
- [GitHub CLI](https://cli.github.com/) (optional)

---

## Repository & GitHub Setup


### Personal Access Tokens (PATs)

Create two GitHub PATs:

- **ArgoCD Read Access PAT**: `repo:read` (for ArgoCD to sync manifests)
- **Deployments Write Access PAT**: `repo:write`, `workflow` (for CI/CD workflows)

Store these as secrets in the `dev` and `prod` GitHub environments.


### Repository Variables

Configure these in your GitHub repository:

- `AZURE_CLIENT_ID`: Azure service principal client ID.
- `AZURE_SUBSCRIPTION_ID`: Azure subscription ID.
- `AZURE_TENANT_ID`: Azure tenant ID.

### GitHub Environments

Create two environments in your repository:

- **dev**: For development deployments. Add required secrets/variables and enable branch protection.
- **prod**: For production deployments. Add required secrets/variables and enable stricter branch protection.

---

## Azure & Terraform Setup

### Login to Azure

```sh
az login
az account list --output table
export ARM_SUBSCRIPTION_ID=$(az account list --output tsv --query "[<subscription-index>].id")
```

### Create Prerequisties Resources

The terraform plan in [](./terraform/bootstrap) has definitions for prerequisite resources:

- The remote backend configuration on Azure
- The service principal for Terraform on CI/CD
- The OIDC federated credentials for Terraform running through GitHub Actions
- Resource Groups for allocating different resources to different environments (dev/prod)
- The minimal roles assigned to the Terraform SP, which includes:
  - Contributor role to the resource groups
  - User Access role to the resource groups
  - Data Blob Storage Contributor role to the backend storage container

[Create backend resources](./scripts/terraform-bootstrap.sh)

### Create Infrastructure Environments

Use the provided workflows to create Terraform environments:

- [Terraform Apply Environment](https://github.com/m-ahmedy/pwc-devops-task-infra/actions/workflows/terraform-apply-env.yaml)

---

## Kubernetes & ArgoCD Setup

### Get Cluster Kubeconfig

Retrieve AKS cluster kubeconfig for dev and prod:

- [Get Cluster Kubeconfig](./scripts/get-cluster-kubeconfig.sh)

Test with:

```sh
kubectl config get-contexts
kubectl version
```

### Generate ACR Tokens

Generate Azure Container Registry tokens:

- [Generate ACR Token](./scripts/generate-docker-credentials.sh)

Set these as secrets/variables in your application repo.

### Run Deployment Workflow

Run the [deployment workflow](https://github.com/m-ahmedy/pwc-devops-task-app/actions/workflows/cd.yaml) in the application code repo to build and push a Docker image to ACR.

### Install ArgoCD

Install ArgoCD into your Kubernetes cluster, only on prod environment:

- [Install ArgoCD](./scripts/install-argocd.sh)

### Log in to ArgoCD

Expose ArgoCD UI:

```sh
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Get initial admin password:

```sh
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath={.data.password} | base64 -d && echo
```

Log in:

```sh
argocd login localhost:8080 --username admin --password <ARGOCD_ADMIN_PASSWORD> --insecure
```

### Import Clusters

Import clusters into ArgoCD using the CLI from your kubeconfig contexts:

```sh
# List available contexts
kubectl config get-contexts

# Import a context (replace <context-name> with your context)
argocd cluster add <context-name>
```

Repeat for each environment (e.g., dev, prod) to allow ArgoCD to manage resources in those clusters.

**Output**

![](./media/clusters.png)

### Create the App of Apps root app

The **App of Apps** architecture in ArgoCD is a pattern where a single "root" ArgoCD Application manages other ArgoCD Application resources. This enables you to declaratively manage multiple applications and environments from a single entry point, improving scalability and maintainability.

To apply the root App of Apps manifest, run:

```sh
kubectl apply -f ./argocd/root/root.yaml
```

This will create the root ArgoCD Application, which in turn will create and manage all child applications as defined in the manifest.

### Generate ArgoCD Manifests

Generate ArgoCD manifests using the automation script:

```sh
cd ./argocd/generator
pip install -r requirements.txt
python3 main.py
```

Set up your `input.json` file with values similar to the provided [`input.sample.json`](./argocd/generator/input.sample.json) template. This file should contain environment-specific configuration such as application name, namespaces, image tags, and other deployment parameters.

Update the values as needed for your deployment scenario before running the generator script.

Apply manifests:

```sh
kubectl apply -f ./output/
```

### Copy the generated application manifest to `the argocd/apps` directory

```
cp argocd/generator/output/application.yaml argocd/apps/<APP_NAME>.yaml
```

**Output**

![](./media/app-of-apps.png)

![](./media/apps.png)

> **Note:** If the production app remains in a "progressing" state in ArgoCD, it is likely due to the AKS cluster being unable to provision additional LoadBalancers. This is caused by the current Azure subscription's limit of 3 public IP addresses, which prevents the creation of new public IPs required for LoadBalancer services.

![](./media/prod-app-stuck.png)

### Access the App

Get the LoadBalancer external IP:

```sh
kubectl get svc -n simple-web-app -o jsonpath="{.items[0].status.loadBalancer.ingress[0].ip}"
```

Endpoints:

```
http://<load-balancer-ip>:5000/users
http://<load-balancer-ip>:5000/users/<user-id>
http://<load-balancer-ip>:5000/products
http://<load-balancer-ip>:5000/products/<product-id>
```

---

## Final Outputs

**App Resources**

![](./media/dev-app-components.png)

**App Network Details**

![](./media/dev-app-network.png)

**Curl Outputs**

![](./media/curl-outputs.png)


## Destroy the environments

Environments can be destroyed via the [Destroy Terraform Environment Workflow](https://github.com/m-ahmedy/pwc-devops-task-infra/actions/workflows/terraform-destroy-env.yaml).


## Potential room for improvement

This project follows GitOps practices, which help keep things organized and reliable. Still, there are a few ways it could be improved, such as:

- **Introduce Monitoring & Logging**: Integrate a monitoring and logging stack (e.g., Prometheus, Grafana, Loki, ELK) to gain visibility into infrastructure and application health.
- **Enhance Observability**: Implement distributed tracing and metrics collection for better observability and faster troubleshooting.
- **Security Hardening**: Apply security best practices in CI/CD pipelines (e.g., secret scanning, least privilege for service principals, dependency vulnerability checks) and across infrastructure layers.
- **Leverage Terragrunt**: Use Terragrunt to manage Terraform configurations, reduce code duplication, and simplify environment management.
- **Automate ArgoCD Setup**: Automate the creation of ArgoCD repositories and application resources as part of the CI/CD process to ensure consistency and reduce manual steps.
- **Policy as Code**: Integrate tools like OPA/Gatekeeper for policy enforcement on Kubernetes resources.
- **Automated Testing**: Add infrastructure and deployment validation tests (e.g., using Terratest or Checkov) to catch misconfigurations early.
- **Documentation Automation**: Generate and maintain up-to-date documentation for infrastructure and deployment processes.
