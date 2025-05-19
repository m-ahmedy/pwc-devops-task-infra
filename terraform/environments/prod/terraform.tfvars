
location    = "East US"
environment = "prod"

registry_config = {
  resource_group_name = "pwc-dev-acr-rg"
  name                = "pwcdevacr"
  sku                 = "Standard"
}

cluster_config = {
  resource_group_name = "pwc-prod-cluster-rg"
  name       = "pwc-prod-cluster"
  dns_prefix = "pwcprodcluster"
  node_count = 2
  vm_size    = "standard_a2_v2"
}
