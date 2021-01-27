#### Dependencies ####
# - Resource Group
# - infrastructure/network.tf
# - infrastructure/storage.tf
# - data.tf (pulls remote state from the above Terraform)
# - eventhubs.tf
# - datasci_nodes.tf

module "datasci_containers" {
  source                    = "../../modules/mod-azure-datasci-containers"
  resource_group_name       = var.resource_group_name
  location                  = var.location
  environment               = var.environment
  cluster_name              = var.cluster_name
  default_tags              = var.default_tags
  admin_username            = var.admin_username
  mqtt_topics               = var.mqtt_topics
  mqtt_users                = var.mqtt_users
  mqtt_eventhubs_batch_size = "10"
  mqtt_scheduled_interval   = "500"

  consul_server               = module.datasci_nodes.consul_server_ip
  namespace_connection_string = module.eventhubs_mqtt.namespace_connection_string

  network_profile_id           = data.terraform_remote_state.infrastructure.outputs.network_datasci_net_profile_id
  share_name_mqtt              = data.terraform_remote_state.infrastructure.outputs.storage_share_mqtt_broker_name
  share_name_connector_config  = data.terraform_remote_state.infrastructure.outputs.storage_share_connector_config_name
  share_name_connector_log     = data.terraform_remote_state.infrastructure.outputs.storage_share_connector_logs_name
  share_name_mqttconsulgateway = data.terraform_remote_state.infrastructure.outputs.storage_share_consul_config_name
  volume_storage_account_name  = data.terraform_remote_state.infrastructure.outputs.mqtt_storage_account_name
  volume_storage_account_key   = data.terraform_remote_state.infrastructure.outputs.mqtt_storage_account_primary_key
  mqtt_broker_share_name       = data.terraform_remote_state.infrastructure.outputs.storage_share_mqtt_broker_name
  mqtt_config_share_name       = data.terraform_remote_state.infrastructure.outputs.storage_share_connector_config_name
  consul_config_share_name     = data.terraform_remote_state.infrastructure.outputs.storage_share_consul_config_name
  storage_account_name         = data.terraform_remote_state.infrastructure.outputs.mqtt_storage_account_name
  storage_account_key          = data.terraform_remote_state.infrastructure.outputs.mqtt_storage_account_primary_key
}
