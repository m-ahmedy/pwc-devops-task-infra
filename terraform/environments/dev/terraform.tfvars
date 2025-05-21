
location    = "East US"
environment = "dev"

registry_config = {
  resource_group_name = "pwc-dev-rg"
  name                = "pwcdevacr"
  sku                 = "Standard"
}

cluster_config = {
  resource_group_name = "pwc-dev-rg"
  name       = "pwc-dev-cluster"
  dns_prefix = "pwcdevcluster"
  node_count = 1
  vm_size    = "standard_a2_v2"
}
