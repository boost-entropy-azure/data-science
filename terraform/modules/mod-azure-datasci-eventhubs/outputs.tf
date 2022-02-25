output "namespace_view_primary_key" {
  description = "primary access key for the namespace for the view auth rule"
  value       = azurerm_eventhub_namespace_authorization_rule.view_auth_rule.primary_key
}

output "namespace_view_secondary_key" {
  description = "secondary access key for the namespace for the view auth rule"
  value       = azurerm_eventhub_namespace_authorization_rule.view_auth_rule.secondary_key
}

output "namespace_view_auth_rule_name" {
  description = "The shared access policy name for accessing the namespace for the view auth rule"
  value       = azurerm_eventhub_namespace_authorization_rule.view_auth_rule.name
}

output "namespace_postgres_connector_primary_key" {
  description = "primary access key for the namespace for the postgres connector auth rule"
  value       = azurerm_eventhub_namespace_authorization_rule.postgres_connector_auth_rule.primary_key
}

output "namespace_postgres_connector_secondary_key" {
  description = "secondary access key for the namespace for the postgres connector auth rule"
  value       = azurerm_eventhub_namespace_authorization_rule.postgres_connector_auth_rule.secondary_key
}

output "namespace_postgres_connector_auth_rule_name" {
  description = "The shared access policy name for accessing the namespace for the postgres connector auth rule"
  value       = azurerm_eventhub_namespace_authorization_rule.postgres_connector_auth_rule.name
}

output "namespace_datahub_connector_primary_key" {
  description = "primary access key for the namespace for the datahub connector auth rule"
  value       = azurerm_eventhub_namespace_authorization_rule.datahub_connector_auth_rule.primary_key
}

output "namespace_datahub_connector_secondary_key" {
  description = "secondary access key for the namespace for the datahub connector auth rule"
  value       = azurerm_eventhub_namespace_authorization_rule.datahub_connector_auth_rule.secondary_key
}

output "namespace_datahub_connector_auth_rule_name" {
  description = "The shared access policy name for accessing the namespace for the datahub connector auth rule"
  value       = azurerm_eventhub_namespace_authorization_rule.datahub_connector_auth_rule.name
}

output "namespace_fqn" {
  description = "fully qualified namesapce for event hub"
  value       = element(split("/", element(split(";", azurerm_eventhub_namespace.eventhubs.default_primary_connection_string), 0)), 2)
}

output "namespace_connection_string" {
  description = "Connection string to the eventhub namespace"
  value       = azurerm_eventhub_namespace.eventhubs.default_primary_connection_string
}

# TODO - need to find a way to output the eventhub ID of the photo_message eventhub topic
# output "eventhub_id" {
#   description = "The ID of the eventhub"
#   value       = azurerm_eventhub.topic[0].id
# }
