provider "azurerm" {
  features {}
}

# Create Azure Event Hubs Namespace
resource "azurerm_eventhub_namespace" "eventhubs" {
  name                = join("-", [var.namespace_name, "namespace"])
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  capacity            = 1
  tags                = var.default_tags
}

# Create an Azure Event Hub for each Topic defined
resource "azurerm_eventhub" "topic" {
  for_each = toset(var.topics)

  name                = each.key
  namespace_name      = azurerm_eventhub_namespace.eventhubs.name
  resource_group_name = var.resource_group_name
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

# Add auth policies so that client apps can interact with the above eventhub instances

resource "azurerm_eventhub_namespace_authorization_rule" "view_auth_rule" {
  depends_on          = [azurerm_eventhub_namespace.eventhubs, azurerm_eventhub.topic]
  name                = "view"
  namespace_name      = azurerm_eventhub_namespace.eventhubs.name
  resource_group_name = azurerm_eventhub_namespace.eventhubs.resource_group_name

  listen = true
  send   = false
  manage = false
}

resource "azurerm_eventhub_namespace_authorization_rule" "postgres_connector_auth_rule" {
  depends_on          = [azurerm_eventhub_namespace.eventhubs, azurerm_eventhub.topic]
  name                = "postgres-connector"
  namespace_name      = azurerm_eventhub_namespace.eventhubs.name
  resource_group_name = azurerm_eventhub_namespace.eventhubs.resource_group_name

  listen = true
  send   = false
  manage = false
}

resource "azurerm_eventhub_consumer_group" "fe_consumer_group" {
  for_each            = toset(var.topics)
  name                = "frontend"
  namespace_name      = azurerm_eventhub_namespace.eventhubs.name
  eventhub_name       = each.key
  resource_group_name = var.resource_group_name
  depends_on          = [azurerm_eventhub_namespace.eventhubs, azurerm_eventhub_namespace_authorization_rule.postgres_connector_auth_rule]
}

resource "azurerm_eventhub_consumer_group" "view_consumer_group" {
  for_each            = toset(var.topics)
  name                = "view"
  namespace_name      = azurerm_eventhub_namespace.eventhubs.name
  eventhub_name       = each.key
  resource_group_name = var.resource_group_name
  depends_on          = [azurerm_eventhub_namespace.eventhubs, azurerm_eventhub_namespace_authorization_rule.view_auth_rule]
}
