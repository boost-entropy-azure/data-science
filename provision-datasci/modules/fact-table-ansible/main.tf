resource "random_id" "default" {
  byte_length = 8
}

data "archive_file" "default" {
  type        = "zip"
  source_dir  = path.module
  output_path = "${path.module}/${random_id.default.hex}.zip"
}

# Create public IP address
resource "azurerm_public_ip" "fact_ip" {
  count               = var.node_count
  name                = join("", ["pip-", var.sub_cluster_name, "-", var.environment, count.index])
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  allocation_method   = "Static"
  domain_name_label   = join("", [var.sub_cluster_name, "-", var.environment, count.index])

  tags = merge(
    var.default_tags,
    map("name", "fact")
  )
}

# Create network interface
resource "azurerm_network_interface" "fact_nic" {
  count               = var.node_count
  name                = join("-", ["nic", var.sub_cluster_name, var.environment, count.index])
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  tags = var.default_tags

  ip_configuration {
    name                          = "fact_nicConfiguration"
    subnet_id                     = var.parent_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(concat(azurerm_public_ip.fact_ip.*.id, list("")), count.index)
  }
}

# Generate random text for a unique storage account name
resource "random_id" "fact_randomStorageId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = var.resource_group.name
  }

  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "fact_boot_storage" {
  name                     = "stdiag${random_id.fact_randomStorageId.hex}"
  resource_group_name      = var.resource_group.name
  location                 = var.resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.default_tags
}

# Create fact virtual machine
resource "azurerm_virtual_machine" "fact_node" {
  count                 = var.node_count
  name                  = join("", ["vm-", var.sub_cluster_name, "-", var.environment, count.index])
  location              = var.resource_group.location
  resource_group_name   = var.resource_group.name
  network_interface_ids = [element(azurerm_network_interface.fact_nic.*.id, count.index)]
  vm_size               = "Standard_DS1_v2"

  tags = var.default_tags

  storage_os_disk {
    name              = join("", ["diskfact", "_", var.environment])
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
    computer_name  = join("", [var.sub_cluster_name, var.environment, count.index])
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
    storage_uri = azurerm_storage_account.fact_boot_storage.primary_blob_endpoint
  }
}

resource "null_resource" "fact-provisioner" {
  depends_on = ["data.archive_file.default"]

  triggers = {
    signature = data.archive_file.default.output_md5
    command = "ansible-playbook -e admin_username=${var.admin_username} -e nodes=${join(",", compact([for pip in azurerm_public_ip.fact_ip : pip.fqdn]))} ${path.module}/postgres_play.yml"
  }

  connection {
    user        = var.admin_username
    host        = azurerm_public_ip.fact_ip[0].ip_address # TODO: assumption made that if one node is up all nodes are ready to start Ansible on
    type        = "ssh"
    timeout     = "10m"
  }

  provisioner "remote-exec" {
    script    = "${path.module}/wait_for_instance.sh"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -e admin_username=${var.admin_username} -e nodes=${join(",", compact([for pip in azurerm_public_ip.fact_ip : pip.fqdn]))} ${path.module}/postgres_play.yml"
  }
}
