
location    = "East US"
environment = "prod"

registry_config = {
  resource_group_name = "pwc-dev-rg"
  name                = "pwcdevacr"
  sku                 = "Standard"
}

cluster_config = {
  resource_group_name = "pwc-prod-rg"
  name       = "pwc-prod-cluster"
  dns_prefix = "pwcprodcluster"
  node_count = 1
  vm_size    = "standard_a2_v2"
}
