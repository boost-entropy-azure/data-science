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
  depends_on = [azurerm_eventhub_namespace.eventhubs]
  for_each            = var.topics

  name                = join("-", [each.key, "auth-rule"])
  resource_group_name = var.resource_group
  namespace_name      = azurerm_eventhub_namespace.eventhubs.name
  eventhub_name       = each.key
  listen              = var.listen
  send                = var.send
  manage              = var.manage
}

resource "azurerm_eventhub_consumer_group" "fe_consumer_group" {
  for_each            = var.topics
  name                = "frontend"
  namespace_name      = azurerm_eventhub_namespace.eventhubs.name
  eventhub_name       = each.key
  resource_group_name = var.resource_group
  depends_on = [azurerm_eventhub_namespace.eventhubs]
}

output "namespace_connection_string" {
    description = "Connection string to the eventhub namespace"
    value    = azurerm_eventhub_namespace.eventhubs.default_primary_connection_string
}

output "namespace_fqn" {
  description = "fully qualified namesapce for event hub"
  value = azurerm_eventhub_namespace.eventhubs.id
}

output "topic_primary_key" {
  description = "primary access key for the topic"
  value = values(azurerm_eventhub_authorization_rule.eventhub_auth_rule)[*].primary_key
}

output "topic_secondary_key" {
  description = "secondary access key for the topic"
  value = values(azurerm_eventhub_authorization_rule.eventhub_auth_rule)[*].secondary_key
}

output "topic_shared_access_policy_name" {
  description = "The shared access policy name for accessing the topic"
  value = values(azurerm_eventhub_authorization_rule.eventhub_auth_rule)[*].name
}
