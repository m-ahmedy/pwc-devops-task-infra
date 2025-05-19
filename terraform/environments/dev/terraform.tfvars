
location    = "East US"
environment = "dev"

registry_config = {
  resource_group_name = "pwc-dev-acr-rg"
  name                = "pwcdevacr"
  sku                 = "Standard"
}

cluster_config = {
  resource_group_name = "pwc-dev-cluster-rg"
  name       = "pwc-dev-cluster"
  dns_prefix = "pwcdevcluster"
  node_count = 2
  vm_size    = "standard_a2_v2"
}
