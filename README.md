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
az account list --output table
```

To set your subscription ID, run:

```sh
export ARM_SUBSCRIPTION_ID=$(az account list --output tsv --query "[<subscription-index>].id")
```

#### Create Terraform Service Principal on Azure

A Service Principal in Azure is an identity used by applications, scripts, or automation tools to access Azure resources securely.

In the context of Terraform. a Service Principal allows Terraform to authenticate with Azure and manage resources (such as creating, updating, or deleting infrastructure) on your behalf, without using your personal credentials. This improves security and enables automated, repeatable deployments.

Utility script is provided:

- [Create Terraform Service Principal](./scripts/create-terraform-sp.sh)

**Note**: The output `terraform-sp.json` will contain sensitive information, use with caution

Fill in the required variables from the output in the [repo config](./README.md#github-repository-configuration).

#### Create OIDC federated credentials on Azure for Terraform Service Principal

Configure OIDC authentication in your GitHub Actions workflows by referencing the [GitHub OIDC documentation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-cloud-providers). This enables secure, short-lived authentication from GitHub to Azure without storing long-lived secrets.

- [Create OIDC Provider](./scripts/create-oidc-provider.sh)

**Note**: create two federated credentials for `dev` and `prod` environments, must match the environments defined [here](./README.md#github-environments).

#### Create bootstrap storage container for holding environment backends

Create an Azure Storage Account and container to store Terraform state files (remote backend). This ensures state consistency and enables team collaboration. Use the provided scripts to create the backend resources:

- [Create backend resources](./scripts/create-terraform-backend.sh)

#### Assign data contributor role to the Terraform SP

Assign Data Contributor Role to allow Terraform SP to store and update the state from a central source of truth.

- [Assign Data Contributor Role to the Terraform SP](./scripts/assign-role-to-terraform-sp.sh)

#### Create the infrastructure environments (dev/prod)

Use the provided workflows to create Terraform environments

- [Terraform Apply Environment](https://github.com/m-ahmedy/pwc-devops-task-infra/actions/workflows/terraform-apply-env.yaml)

#### Get cluster kubeconfig

Use the provided script to get the AKS cluster kubeconfig, the required values can be found in the environment Terraform outputs:

- [Get Cluster Kubeconfig](./scripts/get-cluster-kubeconfig.sh)

Test the new setup with:

```sh
kubectl config get-contexts
kubectl version
```

#### Generate ACR tokens

To generate Azure Container Registry (ACR) tokens, use the provided utility script, the required values can be found in the environment Terraform outputs:

- [Generate ACR Token](./scripts/generate-docker-credentials.sh)

Run the script and follow the prompts to obtain the required token values. Once generated, set these values as secrets or variables in your application repository to enable secure access to the ACR from your CI/CD workflows or Kubernetes cluster.

#### Run the deployment workflow in the applicaiton code repo

It will create and push a fresh docker image to the ACR.

#### ArgoCD Setup

##### Install ArgoCD into the Cluster

ArgoCD is a declarative, GitOps continuous delivery tool for Kubernetes. It automates the deployment of applications by syncing Kubernetes manifests from a Git repository to your cluster.

To install ArgoCD, use the provided helper script:

- [Install ArgoCD](./scripts/install-argocd.sh)

This script will deploy ArgoCD into your Kubernetes cluster and configure the necessary resources.

##### Create ArgoCD manifests

You can generate ArgoCD manifests using the automation script provided in `./argocd/main.py`. This script helps you create templated ArgoCD Application manifests for different environments.

Set the required environment variables before running the script. Here is a sample:

```sh
cd ./argocd
pip install -r requirements.txt
python3 main.py
```

- `REPO_URL`: HTTPS Repo URL
- `REPO_NAME`: The name of the infra repo
- `REPO_USERNAME`: The owner of the infra repo
- `REPO_TOKEN`: The GitHub PAT created for ArgoCD
- `PROJECT_NAME`: The name of the ArgoCD project
- `APP_NAME`: App name
- `DEST_NAMESPACE`: The namespace to create the app
- `DEST_SERVER`: The server to create the app
- `ENVIRONMENTS`: Environments to create the app into

The script will output ArgoCD Application manifests in the `./output/` directory. Review and apply these manifests to your cluster:

```sh
kubectl apply -f ./output/
```

##### Log in to ArgoCD

To access the ArgoCD UI, expose the service or use port-forwarding:

```sh
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

To get the initial admin secret of ArgoCD:

```sh
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath={.data.password} | base64 -d && echo
```

Log in to ArgoCD dashboard on `localhost:8080` or ArgoCD CLI:

```sh
argocd login localhost:8080 --username admin --password <ARGOCD_ADMIN_PASSWORD> --insecure
```

##### Access the App

To access your application via the LoadBalancer service, retrieve its external IP address with:

```sh
kubectl get svc -n simple-web-app -o jsonpath="{.items[?(@.spec.type=='LoadBalancer')].status.loadBalancer.ingress[0].ip}"
```

Once the external IP is available, open it in your browser to access the deployed app.

Available endpoints for this app are:

```
http://<load-balancer-ip>:5000/users
http://<load-balancer-ip>:5000/users/<user-id>

http://<load-balancer-ip>:5000/products
http://<load-balancer-ip>:5000/products/<product-id>
```
