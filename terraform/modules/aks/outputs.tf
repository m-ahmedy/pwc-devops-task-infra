
output "cluster_resource_group" {
  value = var.resource_group_name
}

output "cluster_name" {
  value = var.cluster_name
}

output "object_id" {
  value = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].object_id
  sensitive = true
}
