# Create Azure Event Hubs Namespace
resource "azurerm_eventhub_namespace" "eventhubs" {
  name                = join("-", [var.namespace_name, "namespace"])
  location            = var.location
  resource_group_name = var.resource_group
  sku                 = "Standard"
  capacity            = 1
  tags                = var.default_tags
}

# Create an Azure Event Hub for each Topic defined
resource "azurerm_eventhub" "topic" {
  for_each            = var.topics

  name                = each.key
  namespace_name      = azurerm_eventhub_namespace.eventhubs.name
  resource_group_name = var.resource_group
  partition_count     = 2
  message_retention   = 1

  capture_description {
    enabled             = true
    encoding            = "Avro"
    interval_in_seconds = 300       # 5 min
    size_limit_in_bytes = 314572800 # 300 MB
    skip_empty_archives = true

    destination {
      name                = "EventHubArchive.AzureBlockBlob"
      archive_name_format = "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}"
      blob_container_name = var.datalake_container
      storage_account_id  = var.storage_account_id
    }
  }
}

# Add a rule so that client apps can interract with the above eventhub instances
resource "azurerm_eventhub_authorization_rule" "eventhub_auth_rule" {
  for_each            = var.topics

  name                = join("-", [each.key, "auth-rule"])
  resource_group_name = var.resource_group
  namespace_name      = azurerm_eventhub_namespace.eventhubs.name
  eventhub_name       = each.key
  listen              = var.listen
  send                = var.send
  manage              = var.manage
}

output "namespace_connection_string" {
    description = "Connection string to the eventhub namespace"
    value    = azurerm_eventhub_namespace.eventhubs.default_primary_connection_string
}