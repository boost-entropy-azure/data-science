#### Dependencies ####
# - resource_group.tf
# - network.tf
# - data.tf

resource "azurerm_network_security_group" "datasci_nodes_nsg" {
  name                = join("-", ["nsg", var.cluster_name, var.environment])
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = var.default_tags

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = chomp(data.http.myip.body)
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "NOTEB"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9999"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg" {
  subnet_id                 = azurerm_subnet.subnet_data.id
  network_security_group_id = azurerm_network_security_group.datasci_nodes_nsg.id
}

output "security_group_datasci_nodes_nsg" {
  value = azurerm_network_security_group.datasci_nodes_nsg
}
