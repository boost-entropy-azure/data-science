//terraform {
//    backend "azurerm" {
//      storage_account_name = "ststaticcore"
//      container_name       = "terrasform-state"
//      key                  = "dev-datasci.tfstate"
//
//      # Cannot assign to a variable must be retrieved from an environmental variable
//      # sas_token = var.backend_sas
//
//  }
//}

provider "azurerm" {
  version = "~> 2.18.0"
//  version = "= 2.0.0"
  features {}
  disable_terraform_partner_id = true
}

# Create a resource group that all the Azure resources will live in
resource "azurerm_resource_group" "datasci_group" {
  name     = join("-", ["rg", var.cluster_name, var.environment])
  location = var.location

  tags = var.default_tags
}

resource "azurerm_virtual_network" "datasci_net" {
  name                = join("-", ["vnet", var.cluster_name, var.environment])
  resource_group_name = azurerm_resource_group.datasci_group.name
  location            = azurerm_resource_group.datasci_group.location
  address_space       = ["10.0.0.0/16"]

  tags = var.default_tags
}

# Create subnet
resource "azurerm_subnet" "datasci_subnet" {
  name                 = join("-", ["snet", var.cluster_name, var.environment])
  resource_group_name  = azurerm_resource_group.datasci_group.name
  virtual_network_name = azurerm_virtual_network.datasci_net.name
  address_prefix       = "10.0.1.0/24"

  service_endpoints = ["Microsoft.Storage"]
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "datasci_nsg" {
  name                = join("-", ["nsg", var.cluster_name, var.environment])
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

# Create network interface
resource "azurerm_network_interface" "datasci_nic" {
  count               = var.node_count
  name                = join("", ["nic-", var.cluster_name, "-", var.environment, count.index])
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
  name                = join("", ["pip-", var.cluster_name, "-", var.environment, count.index])
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
resource "random_id" "datasci_randomStorageId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.datasci_group.name
  }

  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "datasci_boot_storage" {
  name                     = "stdiag${random_id.datasci_randomStorageId.hex}"
  resource_group_name      = azurerm_resource_group.datasci_group.name
  location                 = azurerm_resource_group.datasci_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.default_tags
}

# Create virtual machine nodes
resource "azurerm_virtual_machine" "datasci_node" {
  count                 = var.node_count
  name                  = join("", ["vm-", var.cluster_name, "-", var.environment, count.index])
  location              = azurerm_resource_group.datasci_group.location
  resource_group_name   = azurerm_resource_group.datasci_group.name
  network_interface_ids = [element(azurerm_network_interface.datasci_nic.*.id, count.index)]
  vm_size               = "Standard_DS1_v2"

  tags = var.default_tags

  storage_os_disk {
    name              = join("", ["disk", var.cluster_name, "_", var.environment, count.index])
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.7"
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

data "http" "myip" {
  url = "http://ipecho.net/plain"
}

# Create a reverse proxy node and configure NGINX to run on it
module "reverse_proxy" {
  source               = "./modules/reverse-proxy-ansible"
  resource_group       = azurerm_resource_group.datasci_group
  cluster_name         = var.cluster_name
  parent_vnetwork_name = azurerm_virtual_network.datasci_net.name
  consul_server        = azurerm_network_interface.datasci_nic[0].ip_configuration[0].private_ip_address
  environment          = var.environment
  default_tags         = var.default_tags
  mqtt_ip_address      = azurerm_container_group.datasci_mqtt.ip_address
  grafana_ip_address   = module.grafana.grafana_ip_address
}

# Create a fact node and configure PostgreSQL to run on it
module "fact-table" {
  source              = "./modules/fact-table-ansible"
  resource_group       = azurerm_resource_group.datasci_group
  parent_vnetwork_name = azurerm_virtual_network.datasci_net.name
  parent_subnet_id     = azurerm_subnet.datasci_subnet.id
  sub_cluster_name     = join("-", [var.cluster_name, var.environment, "fact"])
  consul_server        = azurerm_network_interface.datasci_nic[0].ip_configuration[0].private_ip_address
  environment          = var.environment
  default_tags         = var.default_tags
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
    ip_rules                   = ["127.0.0.1", chomp(data.http.myip.body)]
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

module "mqtt_eventhubs" {
  source             = "./modules/eventhubs"
  namespace_name     = join("-", [var.cluster_name, var.environment, "mqtt-eventhubs"])
  resource_group     = azurerm_resource_group.datasci_group.name
  location           = azurerm_resource_group.datasci_group.location
  topics             = toset(var.mqtt_topics)
  datalake_container = azurerm_template_deployment.datasci_container.name
  storage_account_id = azurerm_storage_account.datasci_lake_storage.id
  default_tags       = var.default_tags
}

module "alert_eventhubs" {
  source             = "./modules/eventhubs"
  namespace_name     = join("-", [var.cluster_name, var.environment, "alert-eventhubs"])
  resource_group     = azurerm_resource_group.datasci_group.name
  location           = azurerm_resource_group.datasci_group.location
  topics             = local.alert_topics
  datalake_container = azurerm_template_deployment.datasci_container.name
  storage_account_id = azurerm_storage_account.datasci_lake_storage.id
  send               = true
  default_tags       = var.default_tags
}

# # Create Azure Event Hubs Namespace for IOThub
# resource "azurerm_eventhub_namespace" "iot_eventhubs" {
#   name                = join("-", [var.cluster_name, var.environment, "iothub-namespace"])
#   resource_group_name = azurerm_resource_group.datasci_group.name
#   location            = azurerm_resource_group.datasci_group.location
#   sku                 = "Standard"
#   capacity            = 1
#   tags                = var.default_tags
# }

# # Create an Azure Event Hub for the IoT Hub traffic
# resource "azurerm_eventhub" "iot_eventhub" {
#   name                = "iot_message"
#   namespace_name      = azurerm_eventhub_namespace.iot_eventhubs.name
#   resource_group_name = azurerm_resource_group.datasci_group.name
#   partition_count     = 2
#   message_retention   = 1

#   capture_description {
#     enabled             = true
#     encoding            = "Avro"
#     interval_in_seconds = 300       # 5 min
#     size_limit_in_bytes = 314572800 # 300 MB
#     skip_empty_archives = true

#     destination {
#       name                = "EventHubArchive.AzureBlockBlob"
#       archive_name_format = "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}"
#       blob_container_name = azurerm_template_deployment.datasci_container.name
#       storage_account_id  = azurerm_storage_account.datasci_lake_storage.id
#     }
#   }
# }

# # Add a rule so the traffic can flow from IoT Hub to Event Hub.
# resource "azurerm_eventhub_authorization_rule" "auth_rule" {
#   resource_group_name = azurerm_resource_group.datasci_group.name
#   namespace_name      = azurerm_eventhub_namespace.iot_eventhubs.name
#   eventhub_name       = azurerm_eventhub.iot_eventhub.name
#   name                = join("-", [var.cluster_name, var.environment, "auth-rule"])
#   send                = true
#   listen              = true
#   manage              = true
# }

# # Create IoT hub
# resource "azurerm_iothub" "datasci_iothub" {
#   name                = join("-", [var.cluster_name, var.environment, "iothub"])
#   resource_group_name = azurerm_resource_group.datasci_group.name
#   location            = azurerm_resource_group.datasci_group.location

#   tags = var.default_tags

#   //noinspection MissingProperty
#   sku {
#     name     = "B1"
#     capacity = "1"
#   }

#   endpoint {
#     connection_string = azurerm_eventhub_authorization_rule.auth_rule.primary_connection_string
#     name              = join("-", [var.cluster_name, "iothub-eventhubs-endpoint"])
#     type              = "AzureIotHub.EventHub"
#   }

#   route {
#     name           = "IotHub2EventHubs"
#     source         = "DeviceMessages"
#     condition      = "true"
#     endpoint_names = [join("-", [var.cluster_name, "iothub-eventhubs-endpoint"])]
#     enabled        = true
#   }
# }

# Create an Azure Storage Account
resource "azurerm_storage_account" "datasci" {
  name                     = join("", ["st", var.cluster_name, var.environment])
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

# Create an Azure File Share for the Consul config Log
resource "azurerm_storage_share" "consul_config" {
  name                 = join("-", [var.cluster_name, var.environment, "consul-config-file-share"])
  storage_account_name = azurerm_storage_account.datasci.name
  quota                = 1
}

locals {
  alert_topics                       = toset(list("alert_message"))
  mqtt_container_dns_name_label      = join("-", [var.cluster_name, var.environment, "mqtt"])
  mqtt-server                        = "tcp://${azurerm_container_group.datasci_mqtt.ip_address}:1883"
  azure-event-hubs-connection-string =  module.mqtt_eventhubs.namespace_connection_string  
}

# Create an Azure File Share for the MQTT Broker
resource "azurerm_storage_share" "mqtt_broker" {
  name                 = join("-", [var.cluster_name, var.environment, "mqtt-broker-file-share"])
  storage_account_name = azurerm_storage_account.datasci.name
  quota                = 10
}

# Create the "config" Directory in the MQTT Broker File Share
resource "azurerm_storage_share_directory" "broker_config" {
  name                 = "config"
  share_name           = azurerm_storage_share.mqtt_broker.name
  storage_account_name = azurerm_storage_account.datasci.name
}

# Upload the MQTT Broker and Connector config files
module "mqtt-broker-conf" {
  source = "./modules/mqtt-broker-config-ansible"
  arguments = [
    "storage_account_name='${azurerm_storage_account.datasci.name}'",
    "storage_account_key='${azurerm_storage_account.datasci.primary_access_key}'",
    "mqtt_broker_share_name='${azurerm_storage_share.mqtt_broker.name}'",
    "mqtt_config_share_name='${azurerm_storage_share.connector_config.name}'",
    "consul_config_share_name='${azurerm_storage_share.consul_config.name}'",
    "mqtt_admin=${var.admin_username}",
    "mqtt_users=${join("\",\"", var.mqtt_users)}",
    "mqtt_server='${local.mqtt-server}'",
    "mqtt_topics='${join("\",\"", var.mqtt_topics)}'",
    "mqtt_eventhubs_connection='${local.azure-event-hubs-connection-string}'",
    "mqtt_eventhubs_batch_size=10",
    "mqtt_scheduled_interval=500",
    "consul_server='${azurerm_network_interface.datasci_nic[0].ip_configuration[0].private_ip_address}'",
    "container_address='${azurerm_container_group.datasci_mqtt.ip_address}'"
  ]
}

# Create subnet for use with containers
resource "azurerm_subnet" "mqtt_subnet" {
  name                 = "mqtt_broker_subnet"
  resource_group_name  = azurerm_resource_group.datasci_group.name
  virtual_network_name = azurerm_virtual_network.datasci_net.name
  address_prefix       = "10.0.4.0/24"

  delegation {
    name = "mqtt_subnet_delegation"

    service_delegation {
      name = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_network_profile" "datasci_net_profile" {
  name                = join("-", [var.cluster_name, var.environment, "net-profile"])
  location            = azurerm_resource_group.datasci_group.location
  resource_group_name = azurerm_resource_group.datasci_group.name

  container_network_interface {
    name = "container_nic"

    ip_configuration {
      name = "cotntainer_ip_config"
      subnet_id = azurerm_subnet.mqtt_subnet.id
    }
  }
}

# Create a Container Group
resource "azurerm_container_group" "datasci_mqtt" {
  name                = join("-", [var.cluster_name, var.environment, "mqtt"])
  resource_group_name = azurerm_resource_group.datasci_group.name
  location            = azurerm_resource_group.datasci_group.location
  ip_address_type     = "private"
  network_profile_id = azurerm_network_profile.datasci_net_profile.id
  os_type             = "Linux"

  tags = var.default_tags

  # MQTT Broker
  container {
    name   = "mqtt"
    image  = "chesapeaketechnology/mqtt-consul:0.1"
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

    volume {
      name       = "mqtt-broker"
      mount_path = "/mosquitto"
      read_only  = "false"
      share_name = azurerm_storage_share.mqtt_broker.name

      storage_account_name = azurerm_storage_account.datasci.name
      storage_account_key  = azurerm_storage_account.datasci.primary_access_key
    }

    environment_variables = {
      "USERS"="${join(",", concat(var.mqtt_users, list(var.admin_username)))}"
    }

  }

  # MQTT to Event Hub Connector
  container {
    name   = "connector"
    image  = "chesapeaketechnology/mqtt-azure-event-hub-connector:0.1.3"
    cpu    = "0.5"
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

  # Consul gateway
  container {
    name   = "mqttconsulgateway"
    image  = "consul"
    cpu    = "0.5"
    memory = "1"

    volume {
      name       = "consul-config"
      mount_path = "/consul/config"
      read_only  = "false"
      share_name = azurerm_storage_share.consul_config.name

      storage_account_name = azurerm_storage_account.datasci.name
      storage_account_key  = azurerm_storage_account.datasci.primary_access_key
    }

    ports {
      port     = 8500
      protocol = "TCP"
    }

    ports {
      port     = 8600
      protocol = "TCP"
    }

    environment_variables = {
      "CONSUL_LOCAL_CONFIG"="{\"disable_update_check\": true}"
      "CONSUL_BIND_INTERFACE"="eth0"
    }
  }
}

locals {
  inventory_map = zipmap(
    [for pip in azurerm_public_ip.datasci_ip: join(":", ["${pip.tags.name}", pip.ip_address, pip.fqdn])],
    [for nic in azurerm_network_interface.datasci_nic: nic.ip_configuration[0].private_ip_address]
  )
  inventory = join(",", [for k, v in "${local.inventory_map}": join(":", [k, v])])
}

# Invoke Ansible provisioner to finish setting up created data node VMs
module "worker-node" {
  source         = "./modules/worker-node-ansible"
  user           = var.admin_username
  envs           = [
    join("=", ["inventory", "${local.inventory}"]),
    join("=", ["resource_group", azurerm_resource_group.datasci_group.name]),
    join("=", ["namespaces", join(",", [
      join("-", [var.cluster_name, var.environment, "mqtt-eventhubs-namespace"]), 
      join("-", [var.cluster_name, var.environment, "alert-eventhubs-namespace"])])
    ])
  ]
  arguments      = [join("", ["--user=", var.admin_username]), "--vault-password-file", var.ansible_pwfile]
  playbook       = "../configure-datasci/datasci_play.yml"
}

module "grafana" {
  source               = "github.com/chesapeaketechnology/terraform-datasci-grafana-cluster"
  location             = azurerm_resource_group.datasci_group.location
  resource_group_name  = azurerm_resource_group.datasci_group.name
  cluster_name          = var.cluster_name
  virtual_network_name = azurerm_virtual_network.datasci_net.name
  environment          = var.environment
  default_tags         = var.default_tags
  grafana_admin_user   = var.grafana_admin_user
  network_profile_id   = azurerm_network_profile.datasci_net_profile.id
  subnet_start_address = "10.0.1.0"
  subnet_end_address   = "10.0.1.255"
  consul_server        = azurerm_network_interface.datasci_nic[0].ip_configuration[0].private_ip_address
  system_topic_settings = {
    topics               = local.alert_topics
    eventhub_keys        = module.alert_eventhubs.topic_primary_key
    eventhub_namespace   = module.alert_eventhubs.namespace_fqn
    eventhub_shared_access_policies = module.alert_eventhubs.topic_shared_access_policy_name
  }
  topic_settings = {
    topics               = toset(var.mqtt_topics)
    eventhub_keys        =  module.mqtt_eventhubs.topic_primary_key
    eventhub_namespace   = module.mqtt_eventhubs.namespace_fqn
    eventhub_shared_access_policies = module.mqtt_eventhubs.topic_shared_access_policy_name
  }
}