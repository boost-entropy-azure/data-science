#### Dependencies ####
# - Resource Group

resource "azurerm_virtual_network" "virtualnet" {
  depends_on          = [var.resource_group_name]
  name                = join("-", ["vnet", var.cluster_name, var.environment])
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = ["10.0.0.0/16"]

  tags = var.default_tags
}

# Create Container Subnet
resource "azurerm_subnet" "subnet_data" {
  name                 = join("-", ["snet", var.cluster_name, var.environment])
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.virtualnet.name
  address_prefixes     = ["10.0.1.0/24"]

  service_endpoints = ["Microsoft.Storage", "Microsoft.EventHub"]
}

# resource "azurerm_public_ip" "public_ip" {
#   count               = var.node_count
#   name                = join("", ["pip-", var.cluster_name, "-", var.environment, count.index])
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   allocation_method   = "Static"
#   domain_name_label   = join("", [var.cluster_name, "-", var.environment, count.index])

#   tags = merge(
#     var.default_tags,
#     tomap({name = "nodes"})
#   )
# }

output "virtualnet_id" {
  value = azurerm_virtual_network.virtualnet.id
}

output "virtualnet_name" {
  value = azurerm_virtual_network.virtualnet.name
}

output "virtualnet_addr_space" {
  value = azurerm_virtual_network.virtualnet.address_space
}

output "network_subnet_data_id" {
  value = azurerm_subnet.subnet_data.id
}

# output "network_public_ip_list" {
#   value = azurerm_public_ip.public_ip.*.id
# }

# output "network_public_fqdn_list" {
#   value = azurerm_public_ip.public_ip.*.fqdn
# }

# output "network_datasci_net_profile_facts" {
#   value = azurerm_network_profile.datasci_net_profile
# }

# output "network_public_ip_facts" {
#   value = azurerm_public_ip.public_ip
# }

# output "network_subnet_data_facts" {
#   value = azurerm_subnet.subnet_data
# }
