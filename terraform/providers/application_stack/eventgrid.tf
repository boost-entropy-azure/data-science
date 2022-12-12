provider "azurerm" {
  features {}
  subscription_id = var.k8s_subscription_id
}

resource "azurerm_eventgrid_system_topic" "blob-events" {
  name                   = join("-", [var.cluster_name, var.environment, "blob-events"])
  resource_group_name    = var.resource_group_name
  location               = var.location
  source_arm_resource_id = data.terraform_remote_state.infrastructure.outputs.storage_account_id
  topic_type             = "Microsoft.Storage.StorageAccounts"
  tags                   = var.default_tags
}

# TODO: This is the missing link between the eventgrid and sync_message eventhub - we're missing the eventhub ID
# resource "azurerm_eventgrid_system_topic_event_subscription" "photo-event-subscription" {
#   name                   = join("-", [var.cluster_name, var.environment, "sync-event-subscription"])
#   resource_group_name    = var.resource_group_name
#   system_topic           = azurerm_eventgrid_system_topic.blob-events.name

#   included_event_types   = ["Microsoft.Storage.BlobCreated"]

#   eventhub_endpoint_id = module.eventhubs_events.eventhub_id
# }
