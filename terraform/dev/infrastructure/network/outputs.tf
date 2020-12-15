output "virtualnet_id" {
  value = azurerm_virtual_network.virtualnet.id
}

output "virtualnet_name" {
  value = azurerm_virtual_network.virtualnet.name
}

output "virtualnet_addr_space" {
  value = azurerm_virtual_network.virtualnet.address_space
}

output "network_subnet_data_facts" {
  value = azurerm_subnet.subnet_data
}

output "network_subnet_data_id" {
  value = azurerm_subnet.subnet_data.id
}

output "network_public_ip_facts" {
  value = azurerm_public_ip.public_ip
}

output "network_public_ip_list" {
  value = azurerm_public_ip.public_ip.*.id
}

output "network_public_fqdn_list" {
  value = azurerm_public_ip.public_ip.*.fqdn
}

output "network_mqtt_subnet_facts" {
  value = azurerm_subnet.mqtt_subnet
}

output "network_datasci_net_profile_facts" {
  value = azurerm_network_profile.datasci_net_profile
}

output "network_datasci_net_profile_id" {
  value = azurerm_network_profile.datasci_net_profile.id
}
