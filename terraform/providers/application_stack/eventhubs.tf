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

# output "eventhubs_alert_topic_primary_key" {
#   value     = module.eventhubs_alert.topic_primary_key
#   sensitive = true
# }

# output "eventhubs_alert_namespace_fqn" {
#   value = module.eventhubs_alert.namespace_fqn
# }

# output "eventhubs_alert_topic_shared_access_policy_name" {
#   value = module.eventhubs_alert.topic_shared_access_policy_name
# }

# output "eventhubs_mqtt_namespace_connection_string" {
#   value = module.eventhubs_mqtt.namespace_connection_string
# }

# output "eventhubs_mqtt_topic_primary_key" {
#   value     = module.eventhubs_mqtt.topic_primary_key
#   sensitive = true
# }

# output "eventhubs_mqtt_namespace_fqn" {
#   value = module.eventhubs_mqtt.namespace_fqn
# }

# output "eventhubs_mqtt_topic_shared_access_policy_name" {
#   value = module.eventhubs_mqtt.topic_shared_access_policy_name
# }
