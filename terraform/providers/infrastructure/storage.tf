#### Dependencies ####
# - Resource Group
# - network.tf
# - data.tf

### STORAGE ACCOUNTS

# datasci_lake_storage
resource "azurerm_storage_account" "lake_storage_account" {
  resource_group_name      = var.resource_group_name
  location                 = var.location
  name                     = join("", [var.cluster_name, var.environment, "lake"])
  account_kind             = "StorageV2"
  account_replication_type = "LRS"
  account_tier             = "Standard"
  is_hns_enabled           = true

  tags = var.default_tags

  network_rules {
    default_action             = "Deny"
    ip_rules                   = ["127.0.0.1", chomp(data.http.myip.body)]
    virtual_network_subnet_ids = [azurerm_subnet.subnet_data.id]
  }
}

## Node Storage
resource "random_id" "randomStorageId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = var.resource_group_name
  }

  byte_length = 8
}

resource "azurerm_storage_account" "boot_storage" {
  name                     = "stdiag${random_id.randomStorageId.hex}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.default_tags
}

# datasci / mqtt
resource "azurerm_storage_account" "mqtt_storage_account" {
  name                     = join("", ["st", var.cluster_name, var.environment])
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.default_tags
}

# CONTAINER STORAGE
resource "azurerm_template_deployment" "datasci_container" {
  name                = join("-", [var.cluster_name, var.environment, "container"])
  resource_group_name = var.resource_group_name
  deployment_mode     = "Incremental"

  depends_on = [
    azurerm_storage_account.lake_storage_account
  ]

  parameters = {
    location           = var.location
    storageAccountName = azurerm_storage_account.lake_storage_account.name
  }

  template_body = file("${path.module}/datasci-container.json")
}

# resource "azurerm_storage_container" "backups" {
#   name                  = "backups"
#   storage_account_name  = azurerm_storage_account.lake_storage_account.name
#   container_access_type = "private"
# }

# resource "azurerm_storage_container" "images" {
#   name                  = "images"
#   storage_account_name  = azurerm_storage_account.lake_storage_account.name
#   container_access_type = "private"
# }


### STORAGE SHARES
# Create an Azure File Share for the Connector Config
resource "azurerm_storage_share" "connector_config" {
  name                 = join("-", [var.cluster_name, var.environment, "connector-config-file-share"])
  storage_account_name = azurerm_storage_account.mqtt_storage_account.name
  quota                = 1
}

# Create an Azure File Share for the Connector Logs
resource "azurerm_storage_share" "connector_logs" {
  name                 = join("-", [var.cluster_name, var.environment, "connector-logs-file-share"])
  storage_account_name = azurerm_storage_account.mqtt_storage_account.name
  quota                = 2
}

# Create an Azure File Share for the Consul config Log
resource "azurerm_storage_share" "consul_config" {
  name                 = join("-", [var.cluster_name, var.environment, "consul-config-file-share"])
  storage_account_name = azurerm_storage_account.mqtt_storage_account.name
  quota                = 1
}

resource "azurerm_storage_share" "mqtt_broker" {
  name                 = join("-", [var.cluster_name, var.environment, "mqtt-broker-file-share"])
  storage_account_name = azurerm_storage_account.mqtt_storage_account.name
  quota                = 10
}

# Create the "config" Directory in the MQTT Broker File Share
resource "azurerm_storage_share_directory" "broker_config" {
  name                 = "config"
  share_name           = azurerm_storage_share.mqtt_broker.name
  storage_account_name = azurerm_storage_account.mqtt_storage_account.name
}


# resource "null_resource" "upload_consul_config_file" {

#   depends_on = [local_file.consul_config_file]

#   provisioner "local-exec" {

#     command = "az storage file upload --share-name ${var.consul_config_share_name} --account-name ${var.storage_account_name} --account-key ${var.storage_account_key} --source ${local_file.consul_config_file.filename}"
#   }
# }

output "storage_account_facts_primary_dfs_endpoint" {
  value = azurerm_storage_account.lake_storage_account.primary_dfs_endpoint
}

output "storage_account_id" {
  value = azurerm_storage_account.lake_storage_account.id
}

output "storage_account_boot_storage_primary_blob_endpoint" {
  value = azurerm_storage_account.boot_storage.primary_blob_endpoint
}

output "mqtt_storage_account_name" {
  value = azurerm_storage_account.mqtt_storage_account.name
}

output "mqtt_storage_account_primary_key" {
  value = azurerm_storage_account.mqtt_storage_account.primary_access_key
}

output "storage_share_connector_config" {
  value = azurerm_storage_share.connector_config
}

output "storage_share_connector_logs" {
  value = azurerm_storage_share.connector_logs
}

output "storage_share_consul_config" {
  value = azurerm_storage_share.consul_config
}

output "storage_share_mqtt_broker" {
  value = azurerm_storage_share.mqtt_broker
}

output "storage_share_directory_mqtt_broker" {
  value = azurerm_storage_share_directory.broker_config
}

output "container_template_deploy" {
  value = azurerm_template_deployment.datasci_container
}

output "container_template_deploy_name" {
  value = azurerm_template_deployment.datasci_container.name
}

output "storage_share_connector_config_name" {
  value = azurerm_storage_share.connector_config.name
}

output "storage_share_connector_logs_name" {
  value = azurerm_storage_share.connector_logs.name
}

output "storage_share_consul_config_name" {
  value = azurerm_storage_share.consul_config.name
}

output "storage_share_mqtt_broker_name" {
  value = azurerm_storage_share.mqtt_broker.name
}

output "storage_share_directory_mqtt_broker_name" {
  value = azurerm_storage_share_directory.broker_config.name
}


# output "storage_account_facts" {
#   value = azurerm_storage_account.lake_storage_account
# }

# output "mqtt_storage_account_facts" {
#   value = azurerm_storage_account.mqtt_storage_account
# }

# output "storage_account_boot_storage_facts" {
#   value = azurerm_storage_account.boot_storage
# }
