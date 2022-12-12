#### Dependencies ####
# - Resource Group

resource "azurerm_virtual_network" "virtualnet" {
  count               = var.manage_virtual_network ? 1 : 0
  depends_on          = [var.resource_group_name]
  name                = var.virtual_network_name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = ["10.0.0.0/16"]

  tags = var.default_tags
}

data "azurerm_virtual_network" "virtualnet" {
  count               = var.manage_virtual_network ? 0 : 1
  name                = var.virtual_network_name
  resource_group_name = var.resource_group_name
}

# # Create Container Subnet
resource "azurerm_subnet" "subnet_data" {
  count                = var.manage_subnet ? 1 : 0
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = ["10.0.1.0/24"]

  service_endpoints = ["Microsoft.Storage", "Microsoft.EventHub"]
}

#use existing subnet from inital deployment since I can't create another subnet in the .7. space
data "azurerm_subnet" "subnet_data" {
  count                = var.manage_subnet ? 0 : 1
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
}

output "virtualnet_id" {
  value = "${var.manage_virtual_network ? azurerm_virtual_network.virtualnet.0.id : data.azurerm_virtual_network.virtualnet.0.id}"
}

output "virtualnet_name" {
  value = "${var.manage_virtual_network ? azurerm_virtual_network.virtualnet.0.name : data.azurerm_virtual_network.virtualnet.0.name}"
}

output "virtualnet_addr_space" {
  value = "${var.manage_virtual_network ? azurerm_virtual_network.virtualnet.0.address_space : data.azurerm_virtual_network.virtualnet.0.address_space}"
}

output "network_subnet_data_id" {
  value = "${var.manage_subnet ? azurerm_subnet.subnet_data.0.id : data.azurerm_subnet.subnet_data.0.id}"
}
