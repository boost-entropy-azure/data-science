#### Dependencies ####
# - infrastructure/resource_group.tf
# - infrastructure/storage.tf
# - data.tf

module "mqtt_eventhubs" {
  source              = "github.com/chesapeaketechnology/terraform-datasci-modules.git//mod-azure-datasci-eventhubs?ref=v0.0.13"
  namespace_name      = join("-", [var.cluster_name, var.environment, "mqtt-eventhubs"])
  resource_group_name = var.resource_group_name
  location            = var.location
  topics              = toset(var.mqtt_topics)
  datalake_container  = data.terraform_remote_state.infrastructure.outputs.container_template_deploy_name
  storage_account_id  = data.terraform_remote_state.infrastructure.outputs.storage_account_id
  default_tags        = var.default_tags
}

module "alert_eventhubs" {
  source              = "github.com/chesapeaketechnology/terraform-datasci-modules.git//mod-azure-datasci-eventhubs?ref=v0.0.13"
  namespace_name      = join("-", [var.cluster_name, var.environment, "alert-eventhubs"])
  resource_group_name = var.resource_group_name
  location            = var.location
  topics              = toset(var.alert_topics)
  datalake_container  = data.terraform_remote_state.infrastructure.outputs.container_template_deploy_name
  storage_account_id  = data.terraform_remote_state.infrastructure.outputs.storage_account_id
  send                = true
  default_tags        = var.default_tags
}

output "eventhubs_alert_topic_primary_key" {
  value = module.alert_eventhubs.topic_primary_key
}

output "eventhubs_alert_namespace_fqn" {
  value = module.alert_eventhubs.namespace_fqn
}

output "eventhubs_alert_topic_shared_access_policy_name" {
  value = module.alert_eventhubs.topic_shared_access_policy_name
}

output "eventhubs_mqtt_namespace_connection_string" {
  value = module.mqtt_eventhubs.namespace_connection_string
}

output "eventhubs_mqtt_topic_primary_key" {
  value = module.mqtt_eventhubs.topic_primary_key
}

output "eventhubs_mqtt_namespace_fqn" {
  value = module.mqtt_eventhubs.namespace_fqn
}

output "eventhubs_mqtt_topic_shared_access_policy_name" {
  value = module.mqtt_eventhubs.topic_shared_access_policy_name
}
