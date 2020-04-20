provider "azurerm" {
  version = "=2.4.0"
  features {}
}

# Create a resource group that all the Azure resources will live in
resource "azurerm_resource_group" "datasci_group" {
  name     = join("-", [var.cluster_name, var.environment, "group"])
  location = var.location

  tags = var.default_tags
}

resource "azurerm_virtual_network" "datasci_net" {
  name                = join("-", [var.cluster_name, var.environment, "net"])
  resource_group_name = azurerm_resource_group.datasci_group.name
  location            = azurerm_resource_group.datasci_group.location
  address_space       = ["10.0.0.0/16"]

  tags = var.default_tags
}

# Create subnet
resource "azurerm_subnet" "datasci_subnet" {
  name                 = "dev_subnet_west"
  resource_group_name  = azurerm_resource_group.datasci_group.name
  virtual_network_name = azurerm_virtual_network.datasci_net.name
  address_prefix       = "10.0.1.0/24"

  service_endpoints = ["Microsoft.Storage"]
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "datasci_nsg" {
  name                = join("-", [var.cluster_name, var.environment])
  location            = azurerm_resource_group.datasci_group.location
  resource_group_name = azurerm_resource_group.datasci_group.name

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
}

# Create network interface
resource "azurerm_network_interface" "datasci_nic" {
  count               = var.node_count
  name                = join("-", [var.cluster_name, var.environment, "NIC${count.index}"])
  location            = azurerm_resource_group.datasci_group.location
  resource_group_name = azurerm_resource_group.datasci_group.name

  tags = var.default_tags

  ip_configuration {
    name                          = "datasci_nicConfiguration"
    subnet_id                     = azurerm_subnet.datasci_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(concat(azurerm_public_ip.datasci_ip.*.id, list("")), count.index)
  }
}

resource "azurerm_subnet_network_security_group_association" "datasci_subnet_nsg" {
  subnet_id                 = azurerm_subnet.datasci_subnet.id
  network_security_group_id = azurerm_network_security_group.datasci_nsg.id
}

# Create public IPs
resource "azurerm_public_ip" "datasci_ip" {
  count               = var.node_count
  name                = join("-", [var.cluster_name, var.environment, "IP${count.index}"])
  location            = azurerm_resource_group.datasci_group.location
  resource_group_name = azurerm_resource_group.datasci_group.name
  allocation_method   = "Static"
  domain_name_label   = join("", [var.cluster_name, "-", var.environment, count.index])

  tags = merge(
    var.default_tags,
    map("name", "nodes")
  )
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
resource "azurerm_storage_account" "datasci_boot_storage" {
  name                     = "diag${random_id.datasci_randomId.hex}"
  resource_group_name      = azurerm_resource_group.datasci_group.name
  location                 = azurerm_resource_group.datasci_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.default_tags
}

# Create virtual machine
resource "azurerm_virtual_machine" "datasci_node" {
  count                 = var.node_count
  name                  = join("", [var.cluster_name, "-", var.environment, count.index])
  location              = azurerm_resource_group.datasci_group.location
  resource_group_name   = azurerm_resource_group.datasci_group.name
  network_interface_ids = [element(azurerm_network_interface.datasci_nic.*.id, count.index)]
  vm_size               = "Standard_DS1_v2"

  tags = var.default_tags

  storage_os_disk {
    name              = join("", [var.cluster_name, "_", var.environment, "disk${count.index}"])
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
    computer_name  = join("", [var.cluster_name, var.environment, count.index])
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
    enabled     = "true"
    storage_uri = azurerm_storage_account.datasci_boot_storage.primary_blob_endpoint
  }
}

# Create data lake storage account
resource azurerm_storage_account "datasci_lake_storage" {
  resource_group_name      = azurerm_resource_group.datasci_group.name
  location                 = azurerm_resource_group.datasci_group.location
  name                     = join("", [var.cluster_name, var.environment, "lakestorage"])
  account_kind             = "StorageV2"
  account_replication_type = "LRS"
  account_tier             = "Standard"
  is_hns_enabled           = true

  tags = var.default_tags

  network_rules {
    default_action             = "Deny"
    ip_rules                   = ["127.0.0.1"]
    virtual_network_subnet_ids = [azurerm_subnet.datasci_subnet.id]
  }
}

# Create a container within the lake storage account
//resource "azurerm_storage_container" "datasci_container" {
//  name                  = join("-", [var.cluster_name, var.environment, "container"])
//  storage_account_name  = azurerm_storage_account.datasci_lake_storage.name
//  container_access_type = "private"
//}

# A bug with Terraform is preventing the above block from working so we use the template below instead
# https://github.com/terraform-providers/terraform-provider-azurerm/issues/2977

resource "azurerm_template_deployment" "datasci_container" {
  name                = join("-", [var.cluster_name, var.environment, "container"])
  resource_group_name = azurerm_resource_group.datasci_group.name
  deployment_mode     = "Incremental"

  depends_on = [
    azurerm_storage_account.datasci_lake_storage
  ]

  parameters = {
    location           = azurerm_resource_group.datasci_group.location
    storageAccountName = azurerm_storage_account.datasci_lake_storage.name
  }

  template_body = file("${path.module}/datasci-container.json")
}

# Create Azure Event Hubs Namespace
resource "azurerm_eventhub_namespace" "datasci" {
  name                = join("-", [var.cluster_name, var.environment, "event-hub-namespace"])
  location            = azurerm_resource_group.datasci_group.location
  resource_group_name = azurerm_resource_group.datasci_group.name
  sku                 = "Standard"
  capacity            = 1

  tags = var.default_tags
}

# Create Azure Event Hubs
resource "azurerm_eventhub" "datasci_event_hubs" {
  name                = join("-", [var.cluster_name, var.environment, "event-hub"])
  namespace_name      = azurerm_eventhub_namespace.datasci.name
  resource_group_name = azurerm_resource_group.datasci_group.name
  partition_count     = 2
  message_retention   = 1

  capture_description {
    enabled             = true
    encoding            = "Avro"
    interval_in_seconds = 300       # 5 min
    size_limit_in_bytes = 314572800 # 300 MB

    destination {
      name                = "EventHubArchive.AzureBlockBlob"
      archive_name_format = "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}"
      blob_container_name = azurerm_template_deployment.datasci_container.name
      storage_account_id  = azurerm_storage_account.datasci_lake_storage.id
    }
  }
}

resource "azurerm_eventhub_authorization_rule" "auth_rule" {
  resource_group_name = azurerm_resource_group.datasci_group.name
  namespace_name      = azurerm_eventhub_namespace.datasci.name
  eventhub_name       = azurerm_eventhub.datasci_event_hubs.name
  name                = join("-", [var.cluster_name, var.environment, "auth-rule"])
  send                = true
  listen              = true
  manage              = true
}

# Create IoT hub
resource "azurerm_iothub" "datasci_iothub" {
  name                = join("-", [var.cluster_name, var.environment, "iothub"])
  resource_group_name = azurerm_resource_group.datasci_group.name
  location            = azurerm_resource_group.datasci_group.location

  tags = var.default_tags

  //noinspection MissingProperty
  sku {
    name     = "B1"
    capacity = "1"
  }

  endpoint {
    connection_string = azurerm_eventhub_authorization_rule.auth_rule.primary_connection_string
    name              = "datasci-iothub-eventhubs-endpoint"
    type              = "AzureIotHub.EventHub"
  }

  route {
    name           = "IotHub2EventHubs"
    source         = "DeviceMessages"
    condition      = "true"
    endpoint_names = ["datasci-iothub-eventhubs-endpoint"]
    enabled        = true
  }
}

# Create an Azure Storage Account
resource "azurerm_storage_account" "datasci" {
  name                     = join("", [var.cluster_name, var.environment, "storageacct"])
  resource_group_name      = azurerm_resource_group.datasci_group.name
  location                 = azurerm_resource_group.datasci_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.default_tags
}

# Create an Azure File Share for the Connector Config
resource "azurerm_storage_share" "connector_config" {
  name                 = join("-", [var.cluster_name, var.environment, "connector-config-file-share"])
  storage_account_name = azurerm_storage_account.datasci.name
  quota                = 1
}

# Create an Azure File Share for the Connector Logs
resource "azurerm_storage_share" "connector_logs" {
  name                 = join("-", [var.cluster_name, var.environment, "connector-logs-file-share"])
  storage_account_name = azurerm_storage_account.datasci.name
  quota                = 2
}

locals {
  mqtt_container_dns_name_label = join("-", [var.cluster_name, var.environment, "mqtt"])
  mqtt-server = "tcp://${local.mqtt_container_dns_name_label}.${var.location}.azurecontainer.console.azure.us:1883"
  mqtt-username = "datasci"
  mqtt-password = "pass"
  azure-event-hubs-connection-string = azurerm_eventhub_namespace.datasci.default_primary_connection_string
}

module "mqtt-conf"  {
  source = "./modules/mqtt-conf-ansible"
  arguments = [
    "mqtt_config_share_name='${azurerm_storage_share.connector_config.name}'",
    "storage_account_name='${azurerm_storage_account.datasci.name}'",
    "storage_account_key='${azurerm_storage_account.datasci.primary_access_key}'",
    "mqtt_server='${local.mqtt-server}'",
    "mqtt_topics='${var.mqtt_topics}'",
    "mqtt_username='${local.mqtt-username}'",
    "mqtt_password='${local.mqtt-password}'",
    "mqtt_eventhubs_connection='${local.azure-event-hubs-connection-string}'",
    "mqtt_eventhubs_batch_size=10",
    "mqtt_scheduled_interval=500"
  ]
}


# Create a Container Group
resource "azurerm_container_group" "datasci_mqtt" {
  name                = join("-", [var.cluster_name, var.environment, "mqtt"])
  resource_group_name = azurerm_resource_group.datasci_group.name
  location            = azurerm_resource_group.datasci_group.location
  ip_address_type     = "public"
  dns_name_label      = local.mqtt_container_dns_name_label
  os_type             = "Linux"

  tags = var.default_tags

  # MQTT Broker
  container {
    name   = "mqtt"
    image  = "eclipse-mosquitto"
    cpu    = "1.0"
    memory = "1.5"

    ports {
      port     = 1883
      protocol = "TCP"
    }
    ports {
      port     = 9001
      protocol = "TCP"
    }
  }

  # MQTT to Event Hub Connector
  container {
    name   = "connector"
    image  = "chesapeaketechnology/mqtt-azure-event-hub-connector:0.0.1"
    cpu    = "1.0"
    memory = "1.5"

    volume {
      name       = "config"
      mount_path = "/mqtt-azure-connector/config"
      read_only  = "true"
      share_name = azurerm_storage_share.connector_config.name

      storage_account_name = azurerm_storage_account.datasci.name
      storage_account_key  = azurerm_storage_account.datasci.primary_access_key
    }

    volume {
      name       = "log"
      mount_path = "/mqtt-azure-connector/log"
      read_only  = "false"
      share_name = azurerm_storage_share.connector_logs.name

      storage_account_name = azurerm_storage_account.datasci.name
      storage_account_key  = azurerm_storage_account.datasci.primary_access_key
    }
  }
}

# Invoke Ansible provisioner to finish setting up created VMs
module "ansible_provisioner" {
  source = "github.com/chesapeaketechnology/terraform-null-ansible"

  rgroup     = azurerm_resource_group.datasci_group.name
  inventory  = [for pip in azurerm_public_ip.datasci_ip : join("", ["${pip.tags.name}:", pip.ip_address])]
  ip         = [for pip in azurerm_public_ip.datasci_ip : pip.ip_address]
  user       = var.admin_username

  arguments  = [join("", ["--user=", var.admin_username]), "--ask-vault-pass"]
  playbook   = "../configure-datasci/datasci_play.yml"
  dry_run    = false
}
