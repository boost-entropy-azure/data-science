resource "random_id" "default" {
  byte_length = 8
}

data "archive_file" "default" {
  type        = "zip"
  source_dir  = path.module
  output_path = "${path.module}/${random_id.default.hex}.zip"
}

# Create nginx public IP address
resource "azurerm_public_ip" "nginx_ip" {
  name                = join("-", [var.cluster_name, var.environment, var.sub_cluster_name, "IP"])
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  allocation_method   = "Static"
  domain_name_label   = join("-", [var.cluster_name, var.environment, var.sub_cluster_name])

  tags = merge(
    var.default_tags,
    map("name", "nginx")
  )
}

# Create network interface
resource "azurerm_network_interface" "nginx_nic" {
  name                = join("-", [var.cluster_name, var.environment, var.sub_cluster_name, "NIC"])
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  tags = var.default_tags

  ip_configuration {
    name                          = "nginx_nicConfiguration"
    subnet_id                     = azurerm_subnet.nginx_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.nginx_ip.id
  }
}

# Create subnet
resource "azurerm_subnet" "nginx_subnet" {
  name                 = join("-", [var.cluster_name, var.environment, var.sub_cluster_name, "subnet"])
  resource_group_name  = var.resource_group.name
  virtual_network_name = var.parent_vnetwork_name
  address_prefix       = "10.0.2.0/24"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "nginx_nsg" {
  name                = join("-", [var.cluster_name, var.environment, var.sub_cluster_name, "NSG"])
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  tags = var.default_tags

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

  security_rule {
    name                       = "HTTP"
    priority                   = 2001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "MQTT"
    priority                   = 201
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8883"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nginx_subnet_nsg" {
  subnet_id                 = azurerm_subnet.nginx_subnet.id
  network_security_group_id = azurerm_network_security_group.nginx_nsg.id
}

# Generate random text for a unique storage account name
resource "random_id" "nginx_randomStorageId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = var.resource_group.name
  }

  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "nginx_boot_storage" {
  name                     = "diag${random_id.nginx_randomStorageId.hex}"
  resource_group_name      = var.resource_group.name
  location                 = var.resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.default_tags
}

# Create nginx virtual machine
resource "azurerm_virtual_machine" "nginx_node" {
  name                  = join("-", [var.cluster_name, var.environment, var.sub_cluster_name])
  location              = var.resource_group.location
  resource_group_name   = var.resource_group.name
  network_interface_ids = [azurerm_network_interface.nginx_nic.id]
  vm_size               = "Standard_DS1_v2"

  tags = var.default_tags

  storage_os_disk {
    name              = join("", ["nginx", "_", var.environment, "disk"])
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS-CI"
    sku       = "7-CI"
    version   = "latest"
  }

  os_profile {
    computer_name  = join("", ["nginx", var.environment])
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
    enabled     = "false"
    storage_uri = azurerm_storage_account.nginx_boot_storage.primary_blob_endpoint
  }
}

resource "null_resource" "nginx-provisioner" {
  depends_on = ["data.archive_file.default"]

  triggers = {
    signature = data.archive_file.default.output_md5
    command = "ansible-playbook -e mqtt_broker=${var.mqtt_ip_address} -e fqdn=${azurerm_public_ip.nginx_ip.fqdn} ${path.module}/nginx_play.yml"
  }

  connection {
    user        = var.admin_username
    host        = azurerm_public_ip.nginx_ip.ip_address
    type        = "ssh"
    timeout     = "10m"
  }

  provisioner "remote-exec" {
    script    = "${path.module}/wait_for_instance.sh"
  }

  provisioner "local-exec" {
    command = "ansible-galaxy install geerlingguy.nginx"
  }

  provisioner "local-exec" {
    command = "ansible-galaxy install geerlingguy.nginx"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -e mqtt_ip_address=${var.mqtt_ip_address} -e fqdn=${azurerm_public_ip.nginx_ip.fqdn} ${path.module}/nginx_play.yml"
  }
}
