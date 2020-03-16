provider "azurerm" {
    version = "=1.44.0"
    subscription_id = "07c2619d-5aa2-43a6-a61c-155b2757fe02"
}

resource "azurerm_resource_group" "datasci_group" {
    name = join("_", ["datasci", var.environment, "group"])
    location = var.location
}

resource "azurerm_virtual_network" "datasci_net" {
    name = join("_", ["datasci", var.environment, "net"])
    resource_group_name = azurerm_resource_group.datasci_group.name
    location = azurerm_resource_group.datasci_group.location
    address_space = ["10.0.0.0/16"]
}

# Create subnet
resource "azurerm_subnet" "datasci_subnet" {
    name                 = "dev_subnet_west"
    resource_group_name  = azurerm_resource_group.datasci_group.name
    virtual_network_name = azurerm_virtual_network.datasci_net.name
    address_prefix       = "10.0.1.0/24"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "datasci_nsg" {
    name                = join("_", ["datasci", var.environment])
    location            = azurerm_resource_group.datasci_group.location
    resource_group_name = azurerm_resource_group.datasci_group.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

# Create network interface
resource "azurerm_network_interface" "datasci_nic" {
    count                     = var.node_count
    name                      = join("_", ["datasci", var.environment, "NIC${count.index}"])
    location                  = azurerm_resource_group.datasci_group.location
    resource_group_name       = azurerm_resource_group.datasci_group.name
    network_security_group_id = azurerm_network_security_group.datasci_nsg.id

    ip_configuration {
        name                          = "datasci_nicConfiguration"
        subnet_id                     = azurerm_subnet.datasci_subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = element(concat(azurerm_public_ip.datasci_ip.*.id, list("")), count.index)
    }
}

# Create public IPs
resource "azurerm_public_ip" "datasci_ip" {
    count                        = var.node_count
    name                         = join("_", ["datasci", var.environment, "IP${count.index}"])
    location                     = azurerm_resource_group.datasci_group.location
    resource_group_name          = azurerm_resource_group.datasci_group.name
    allocation_method            = "Static"
    domain_name_label            = join("", ["datasci-", var.environment, count.index])

    tags = {
        name        = "nodes"
    }
}

# Generate random text for a unique storage account name
resource "random_id" "datasci_randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.datasci_group.name
    }

    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "datasci_storage" {
    name                        = "diag${random_id.datasci_randomId.hex}"
    resource_group_name         = azurerm_resource_group.datasci_group.name
    location                    = azurerm_resource_group.datasci_group.location
    account_tier                = "Standard"
    account_replication_type    = "LRS"
}

# Create virtual machine
resource "azurerm_virtual_machine" "datasci_node" {
    count                 = var.node_count
    name                  = join("", ["datasci-", var.environment, count.index])
    location              = azurerm_resource_group.datasci_group.location
    resource_group_name   = azurerm_resource_group.datasci_group.name
    network_interface_ids = [element(azurerm_network_interface.datasci_nic.*.id, count.index)]
    vm_size               = "Standard_DS1_v2"

    storage_os_disk {
        name              = join("", ["datasci_", var.environment, "disk${count.index}"])
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = join("", ["datasci", var.environment, count.index])
        admin_username = var.admin_username
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = join("", ["/home/", var.admin_username, "/.ssh/authorized_keys"])
            key_data = file("~/.ssh/id_rsa.pub")
        }
    }

    boot_diagnostics {
        enabled = "true"
        storage_uri = azurerm_storage_account.datasci_storage.primary_blob_endpoint
    }
}

# Create IoT hub
resource "azurerm_iothub" "datasci_iothub" {
    name                        = join("-", ["datasci", var.environment, "iothub"])
    resource_group_name         = azurerm_resource_group.datasci_group.name
    location                    = azurerm_resource_group.datasci_group.location

    sku {
        name     = "B1"
        capacity = "1"
    }

    route {
        name           = "defaultroute"
        source         = "DeviceMessages"
        condition      = "true"
        endpoint_names = ["events"]
        enabled        = true
    }
}

module "ansible_provisioner" {
    source    = "github.com/cloudposse/tf_ansible"

    arguments = [join("", ["--user=", var.admin_username])]
    envs      = [for pip in azurerm_public_ip.datasci_ip : join(":", ["inventory=${pip.resource_group_name}", "${pip.tags.name}", "${pip.ip_address}"])]
    playbook  = "../configure-datasci/datasci_play.yml"
    dry_run   = false
}
