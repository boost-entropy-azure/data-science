data "azurerm_resource_group" "k8s_resource_group" {
  count    = var.manage_resource_group ? 0 : 1
  provider = azurerm.k8s
  name     = var.resource_group_name
}

data "azurerm_virtual_network" "k8s_vnet" {
  count               = var.manage_virtual_network ? 0 : 1
  provider            = azurerm.k8s
  name                = var.virtual_network_name
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "k8s_subnet" {
  count                = var.manage_subnet ? 0 : 1
  provider             = azurerm.k8s
  name                 = var.subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.resource_group_name
}

data "azurerm_kubernetes_cluster" "kube" {
  count               = var.manage_aks_cluster ? 0 : 1
  provider            = azurerm.k8s
  name                = var.aks_cluster_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_kubernetes_cluster" "kube" {
  count               = var.manage_aks_cluster ? 1 : 0
  provider            = azurerm.k8s
  name                = join("-", ["aks", var.cluster_name, var.environment])
  depends_on          = [var.resource_group_name]
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = join("-", ["cloud", var.cluster_name, var.environment])

  public_network_access_enabled = false

  default_node_pool {
    name            = "default"
    node_count      = 5
    vm_size         = "Standard_D2_v3"
    vnet_subnet_id  = var.manage_subnet ? "" : data.azurerm_subnet.k8s_subnet.0.id

    tags = var.default_tags
  }

  network_profile {
    load_balancer_sku  = "standard"
    network_plugin     = "kubenet"
    network_policy     = "calico"
  }

  service_principal {
    client_id     = var.remotestate_client_id
    client_secret = var.remotestate_client_secret
  }

  tags = var.default_tags
}

output "aks_kube_config" {
  value = "${var.manage_aks_cluster ? azurerm_kubernetes_cluster.kube[0].kube_config_raw : data.azurerm_kubernetes_cluster.kube[0].kube_config_raw}"
  sensitive = true
}

output "aks_host" {
  value = "${var.manage_aks_cluster ? azurerm_kubernetes_cluster.kube[0].kube_config.0.host : data.azurerm_kubernetes_cluster.kube[0].kube_config.0.host}"
  sensitive = true
}

output "aks_client_certificate" {
  value = "${var.manage_aks_cluster ? azurerm_kubernetes_cluster.kube[0].kube_config.0.client_certificate : data.azurerm_kubernetes_cluster.kube[0].kube_config.0.client_certificate}"
  sensitive = true
}

output "aks_client_key" {
  value = "${var.manage_aks_cluster ? azurerm_kubernetes_cluster.kube[0].kube_config.0.client_key : data.azurerm_kubernetes_cluster.kube[0].kube_config.0.client_key}"
  sensitive = true
}

output "aks_cluster_ca_certificate" {
  value = "${var.manage_aks_cluster ? azurerm_kubernetes_cluster.kube[0].kube_config.0.cluster_ca_certificate : data.azurerm_kubernetes_cluster.kube[0].kube_config.0.cluster_ca_certificate}"
  sensitive = true
}

output "aks_identity" {
  value = "${var.manage_aks_cluster ? azurerm_kubernetes_cluster.kube[0].identity : data.azurerm_kubernetes_cluster.kube[0].identity}"
}

