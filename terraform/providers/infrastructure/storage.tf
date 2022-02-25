#### Dependencies ####
# - Resource Group
# - network.tf
# - data.tf

### STORAGE ACCOUNTS
resource "random_integer" "randomStorageNumber" {
  min = 2
  max = 5

  keepers = {
    # Generate a new integer each time we switch to a new listener ARN
    resource_group = var.resource_group_name
  }
}

# datasci_lake_storage
resource "azurerm_storage_account" "lake_storage_account" {
  resource_group_name      = var.resource_group_name
  location                 = var.location
  name                     = join("", [var.cluster_name, var.environment, "lake", random_integer.randomStorageNumber.result])
  account_kind             = "StorageV2"
  account_replication_type = "LRS"
  account_tier             = "Standard"
  is_hns_enabled           = true

  tags = var.default_tags
}

resource "azurerm_storage_account_network_rules" "lake_storage_account_rules" {
  count                = var.source_from_vault ? 0 : 1
  resource_group_name  = var.resource_group_name
  storage_account_name = azurerm_storage_account.lake_storage_account.name

  default_action             = "Deny"
  ip_rules                   = ["127.0.0.1", chomp(data.http.myip.0.body)]
  virtual_network_subnet_ids = [azurerm_subnet.subnet_data.id]
}

resource "azurerm_storage_account_network_rules" "lake_storage_account_rules_with_vault" {
  count                = var.source_from_vault ? length(local.remote_ips) : 0
  resource_group_name  = var.resource_group_name
  storage_account_name = azurerm_storage_account.lake_storage_account.name

  default_action             = "Deny"
  ip_rules                   = concat(["127.0.0.1"], local.remote_ips)
  virtual_network_subnet_ids = [azurerm_subnet.subnet_data.id]
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

output "storage_account_facts_primary_dfs_endpoint" {
  value = azurerm_storage_account.lake_storage_account.primary_dfs_endpoint
}

output "storage_account_id" {
  value = azurerm_storage_account.lake_storage_account.id
}

output "storage_container_name" {
  value = azurerm_template_deployment.datasci_container.name
}

output "storage_account_boot_storage_primary_blob_endpoint" {
  value = azurerm_storage_account.boot_storage.primary_blob_endpoint
}

output "container_template_deploy" {
  value = azurerm_template_deployment.datasci_container
}

output "container_template_deploy_name" {
  value = azurerm_template_deployment.datasci_container.name
}

output "storage_account_connection_string" {
  description = "The connection string for the postgres connector checkpoint storage account"
  value       = azurerm_storage_account.lake_storage_account.primary_connection_string
  sensitive = true
}

# output "storage_account_facts" {
#   value = azurerm_storage_account.lake_storage_account
# }

# output "storage_account_boot_storage_facts" {
#   value = azurerm_storage_account.boot_storage
# }
