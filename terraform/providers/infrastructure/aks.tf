resource "azurerm_kubernetes_cluster" "kube" {
  name                                = join("-", ["aks", var.cluster_name, var.environment])
  location                            = var.location
  resource_group_name                 = var.resource_group_name
  dns_prefix                          = join("-", ["cloud", var.cluster_name, var.environment])

  public_network_access_enabled       = true
  api_server_authorized_ip_ranges     = var.aks_api_server_authorized_ip_ranges

  default_node_pool {
    name            = "default"
    node_count      = 4
    vm_size         = "Standard_D2_v3"

    tags = var.default_tags
  }

  network_profile {
    load_balancer_sku = "Standard"
    network_plugin    = "kubenet"
    network_policy = "calico"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.default_tags
}

output "aks_kube_config" {
  value = azurerm_kubernetes_cluster.kube.kube_config_raw
  sensitive = true
}

output "aks_host" {
  value = azurerm_kubernetes_cluster.kube.kube_config[0].host
}

output "aks_client_certificate" {
  value = azurerm_kubernetes_cluster.kube.kube_config[0].client_certificate
  sensitive = true
}

output "aks_client_key" {
  value = azurerm_kubernetes_cluster.kube.kube_config[0].client_key
  sensitive = true
}

output "aks_cluster_ca_certificate" {
  value = azurerm_kubernetes_cluster.kube.kube_config[0].cluster_ca_certificate
  sensitive = true
}

output "aks_identity" {
  value = azurerm_kubernetes_cluster.kube.identity
}

