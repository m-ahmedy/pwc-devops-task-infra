
# PwC DevOps Task Infrastructure

This repository contains the infrastructure setup for the PwC DevOps Task. It includes configuration files, scripts, and instructions to provision and manage the required cloud resources using Infrastructure as Code (IaC) tools.


## Directory Structure

```
infra/
├── README.md
├── .github/workflows/   # Containing GitHub Actions CI/CD workflows
├── terraform/           # Terraform scripts for infrastructure provisioning
├── kustomize/           # Kubernetes manifests in Kustomize definitions
├── scripts/             # Helper scripts for automation
└── argocd/              # Helper automation for generating templated ArgoCD manifests
```

## Prerequisites

Before you begin, ensure you have the following tools installed:

- [Git](https://git-scm.com/)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Terraform](https://www.terraform.io/downloads.html)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Docker](https://docs.docker.com/get-docker/) (optional)
- [ArgoCD CLI](https://argo-cd.readthedocs.io/en/stable/cli_installation/) (optional)

## Deployment Instructions

### GitHub Repository Configuration

Before deploying, configure the following in your GitHub repository:

- **Repository Variables**:
    - `AZURE_CLIENT_ID`: Azure service principal client ID.
    - `AZURE_SUBSCRIPTION_ID`: Azure subscription ID.
    - `AZURE_TENANT_ID`: Azure tenant ID.

### GitHub Personal Access Tokens (PATs)

Create two GitHub Personal Access Tokens for integration:

- **ArgoCD Read Access PAT**:  
    - Scope: `repo:read`
    - Purpose: Allows ArgoCD to read repository contents for syncing manifests.

- **Deployments Write Access PAT**:  
    - Scope: `repo:write`, `workflow`
    - Purpose: Enables CI/CD workflows to push changes and trigger deployments.

Store these tokens as secrets in the appropriate GitHub environments (`dev` and `prod`) for secure access.

### GitHub Environments

Create two environments in your repository settings:

#### 1. `dev`
- Used for development deployments.
- Add required secrets and variables to this environment.
- Enable branch protection rules (e.g., require pull request reviews before merging to `dev`).

#### 2. `prod`
- Used for production deployments.
- Add required secrets and variables to this environment.
- Enable stricter branch protection rules (e.g., require status checks, pull request reviews, and deployment approvals before merging to `main`).

### Steps to Deploy

#### Login to Azure and set ARM_SUBSCRIPTION

Logging in to Azure with priviliged access

```sh
az login
```

To get your all subscriptions on the account, run:

```sh
az account list --output table"
```

To set your subscription ID, run:

```sh
export ARM_SUBSCRIPTION_ID=$(az account list --output tsv --query "[<subscription-number>].id")
```

#### Create Terraform Service Principal on Azure

A Service Principal in Azure is an identity used by applications, scripts, or automation tools to access Azure resources securely.

In the context of Terraform. a Service Principal allows Terraform to authenticate with Azure and manage resources (such as creating, updating, or deleting infrastructure) on your behalf, without using your personal credentials. This improves security and enables automated, repeatable deployments.

Utility script provided [here](./scripts/create-terraform-sp.sh)

__Note__: The output `terraform-sp.json` will contain sensitive information, use with caution

Fill in the required variables from the output in the [repo config](./README.md#github-repository-configuration)

#### Create OIDC federated credentials on Azure for Terraform Service Principal

Configure OIDC authentication in your GitHub Actions workflows by referencing the [GitHub OIDC documentation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-cloud-providers). This enables secure, short-lived authentication from GitHub to Azure without storing long-lived secrets.

- [Create OIDC Provider](./scripts/create-oidc-provider.sh)

__Note__: create two federated credentials for `dev` and `prod` environments, must match the environments defined [here](./README.md#github-environments)

#### Create bootstrap storage container for holding environment backends

Create an Azure Storage Account and container to store Terraform state files (remote backend). This ensures state consistency and enables team collaboration. Use the provided scripts to create the backend resources:

- [Create backend resources](./scripts/create-terraform-backend.sh)

#### Assign data contributor role to the Terraform SP

Assign Data Contributor Role to allow Terraform SP to store and update the state from a central source of truth.

- [Assign Data Contributor Role to the Terraform SP](./scripts/assign-role-to-terraform-sp.sh)

#### Create the infrastructure environments (dev/prod)

Use the provided workflows to create Terraform environments

- Apply Terraform Environment

