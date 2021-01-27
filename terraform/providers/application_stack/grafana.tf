#### Dependencies ####
# - Resource Group
# - infrastructure/network.tf
# - infrastructure/storage.tf
# - data.tf (pulls remote state from the above Terraform)
# - datasci_nodes.tf
# - eventhubs.tf
# - status_monitor.tf

module "grafana" {
  source               = "../../modules/mod-azure-datasci-grafana"
  grafana_depends_on   = "prometheus"
  resource_group_name  = var.resource_group_name
  cluster_name         = var.cluster_name
  location             = var.location
  environment          = var.environment
  default_tags         = var.default_tags
  grafana_admin_user   = var.admin_username
  subnet_start_address = "10.0.1.0"
  subnet_end_address   = "10.0.1.255"
  consul_account_name  = data.terraform_remote_state.infrastructure.outputs.mqtt_storage_account_name
  consul_account_key   = data.terraform_remote_state.infrastructure.outputs.mqtt_storage_account_primary_key
  network_profile_id   = data.terraform_remote_state.infrastructure.outputs.network_datasci_net_profile_id
  prometheus_server    = module.status_monitor.prometheus_ip_address
  consul_server        = module.datasci_nodes.consul_server_ip
  system_topic_settings = {
    topics                          = var.alert_topics
    eventhub_keys                   = module.eventhubs_alert.topic_primary_key
    eventhub_namespace              = module.eventhubs_alert.namespace_fqn
    eventhub_shared_access_policies = module.eventhubs_alert.topic_shared_access_policy_name
  }
  topic_settings = {
    topics                          = var.mqtt_topics
    eventhub_keys                   = module.eventhubs_mqtt.topic_primary_key
    eventhub_namespace              = module.eventhubs_mqtt.namespace_fqn
    eventhub_shared_access_policies = module.eventhubs_mqtt.topic_shared_access_policy_name
  }
}

output "grafana_admin_password" {
  value     = module.grafana.grafana_admin_password
  sensitive = true
}

output "grafana_admin_user" {
  value     = module.grafana.grafana_admin_user
  sensitive = false
}
