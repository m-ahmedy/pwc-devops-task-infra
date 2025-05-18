
location            = "East US"
environment         = "prod"

registry_resource_group_name = "rg-pwc-dev-acr"
registry_name       = "pwcdevacr"
registry_sku        = "Standard"

cluster_resource_group_name = "rg-pwc-prod-cluster"
cluster_name        = "pwc-prod-cluster"
cluster_dns_prefix  = "pwcprodcluster"
cluster_node_count  = 2
cluster_vm_size     = "standard_a2_v2"
