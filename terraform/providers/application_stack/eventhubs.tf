#### Dependencies ####
# - Resource Group
# - infrastructure/storage.tf
# - data.tf

module "eventhubs_mqtt" {
  source              = "../../modules/mod-azure-datasci-eventhubs"
  namespace_name      = join("-", [var.cluster_name, var.environment, "mqtt-eventhubs"])
  resource_group_name = var.resource_group_name
  location            = var.location
  topics              = toset(var.mqtt_topics)
  datalake_container  = data.terraform_remote_state.infrastructure.outputs.container_template_deploy_name
  storage_account_id  = data.terraform_remote_state.infrastructure.outputs.storage_account_id
  default_tags        = var.default_tags
}

module "eventhubs_alert" {
  source              = "../../modules/mod-azure-datasci-eventhubs"
  namespace_name      = join("-", [var.cluster_name, var.environment, "alert-eventhubs"])
  resource_group_name = var.resource_group_name
  location            = var.location
  topics              = toset(var.alert_topics)
  datalake_container  = data.terraform_remote_state.infrastructure.outputs.container_template_deploy_name
  storage_account_id  = data.terraform_remote_state.infrastructure.outputs.storage_account_id
  send                = true
  default_tags        = var.default_tags
}

module "eventhubs_events" {
  source              = "../../modules/mod-azure-datasci-eventhubs"
  namespace_name      = join("-", [var.cluster_name, var.environment, "event-eventhubs"])
  resource_group_name = var.resource_group_name
  location            = var.location
  topics              = toset(var.event_topics)
  datalake_container  = data.terraform_remote_state.infrastructure.outputs.container_template_deploy_name
  storage_account_id  = data.terraform_remote_state.infrastructure.outputs.storage_account_id
  default_tags        = var.default_tags
}


//-------- Alert Event Hub Namespace ---------

output "eventhubs_alert_namespace_fqn" {
  description = "The alert event hub namespace FQDN"
  value = module.eventhubs_alert.namespace_fqn
  sensitive = true
}

output "eventhubs_alert_namespace_connection_string" {
  description = "The alert event hub namespace connection string"
  value     = module.eventhubs_alert.namespace_connection_string
  sensitive = true
}

output "eventhubs_alert_view_primary_key" {
  description = "The alert event hub namespace View Auth Rule primary key"
  value     = module.eventhubs_alert.namespace_view_primary_key
  sensitive = true
}

output "eventhubs_alert_view_secondary_key" {
  description = "The alert event hub namespace View Auth Rule secondary key"
  value     = module.eventhubs_alert.namespace_view_secondary_key
  sensitive = true
}

output "eventhubs_alert_view_rule_name" {
  description = "The alert event hub namespace View Auth Rule name"
  value     = module.eventhubs_alert.namespace_view_auth_rule_name
}

output "eventhubs_alert_postgres_connector_primary_key" {
  description = "The alert event hub namespace Postgres Connector Auth Rule primary key"
  value     = module.eventhubs_alert.namespace_postgres_connector_primary_key
  sensitive = true
}

output "eventhubs_alert_postgres_connector_secondary_key" {
  description = "The alert event hub namespace Postgres Connector Auth Rule secondary key"
  value     = module.eventhubs_alert.namespace_postgres_connector_secondary_key
  sensitive = true
}

output "eventhubs_alert_postgres_connector_rule_name" {
  description = "The alert event hub namespace Postgres Connector Auth Rule name"
  value     = module.eventhubs_alert.namespace_postgres_connector_auth_rule_name
}


//-------- MQTT Event Hub Namespace ---------

output "eventhubs_mqtt_namespace_fqn" {
  description = "The mqtt event hub namespace FQDN"
  value = module.eventhubs_mqtt.namespace_fqn
  sensitive = true
}

output "eventhubs_mqtt_namespace_connection_string" {
  description = "The mqtt event hub namespace connection string"
  value     = module.eventhubs_mqtt.namespace_connection_string
  sensitive = true
}

output "eventhubs_mqtt_view_primary_key" {
  description = "The mqtt event hub namespace View Auth Rule primary key"
  value     = module.eventhubs_mqtt.namespace_view_primary_key
  sensitive = true
}

output "eventhubs_mqtt_view_secondary_key" {
  description = "The mqtt event hub namespace View Auth Rule secondary key"
  value     = module.eventhubs_mqtt.namespace_view_secondary_key
  sensitive = true
}

output "eventhubs_mqtt_view_rule_name" {
  description = "The mqtt event hub namespace View Auth Rule name"
  value     = module.eventhubs_mqtt.namespace_view_auth_rule_name
}

output "eventhubs_mqtt_postgres_connector_primary_key" {
  description = "The mqtt event hub namespace Postgres Connector Auth Rule primary key"
  value     = module.eventhubs_mqtt.namespace_postgres_connector_primary_key
  sensitive = true
}

output "eventhubs_mqtt_postgres_connector_secondary_key" {
  description = "The mqtt event hub namespace Postgres Connector Auth Rule secondary key"
  value     = module.eventhubs_mqtt.namespace_postgres_connector_secondary_key
  sensitive = true
}

output "eventhubs_mqtt_postgres_connector_rule_name" {
  description = "The mqtt event hub namespace Postgres Connector Auth Rule name"
  value     = module.eventhubs_mqtt.namespace_postgres_connector_auth_rule_name
}


//-------- Events Event Hub Namespace ---------

output "eventhubs_events_namespace_fqn" {
  description = "The events event hub namespace FQDN"
  value = module.eventhubs_events.namespace_fqn
  sensitive = true
}

output "eventhubs_events_namespace_connection_string" {
  description = "The events event hub namespace connection string"
  value     = module.eventhubs_events.namespace_connection_string
  sensitive = true
}

output "eventhubs_events_view_primary_key" {
  description = "The events event hub namespace View Auth Rule primary key"
  value     = module.eventhubs_events.namespace_view_primary_key
  sensitive = true
}

output "eventhubs_events_view_secondary_key" {
  description = "The events event hub namespace View Auth Rule secondary key"
  value     = module.eventhubs_events.namespace_view_secondary_key
  sensitive = true
}

output "eventhubs_events_view_rule_name" {
  description = "The events event hub namespace View Auth Rule name"
  value     = module.eventhubs_events.namespace_view_auth_rule_name
}

output "eventhubs_events_postgres_connector_primary_key" {
  description = "The events event hub namespace Postgres Connector Auth Rule primary key"
  value     = module.eventhubs_events.namespace_postgres_connector_primary_key
  sensitive = true
}

output "eventhubs_events_postgres_connector_secondary_key" {
  description = "The events event hub namespace Postgres Connector Auth Rule secondary key"
  value     = module.eventhubs_events.namespace_postgres_connector_secondary_key
  sensitive = true
}

output "eventhubs_events_postgres_connector_rule_name" {
  description = "The events event hub namespace Postgres Connector Auth Rule name"
  value     = module.eventhubs_events.namespace_postgres_connector_auth_rule_name
}

# output "eventhubs_events_id" {
#   description = "The ID of the eventhub"
#   value       = module.eventhubs_events.eventhub_id
# }


