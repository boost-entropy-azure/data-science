include {
  path = find_in_parent_folders()
}

dependencies {
  paths = [
    "../../infrastructure/resource_groups/",
    "../../infrastructure/network",
    "../../infrastructure/storage",
    "../datasci_nodes",
    "../eventhubs_alert",
    "../eventhubs_mqtt",
    "../status_monitor"
  ]
}

dependency "resource_groups" {
  config_path = "../../infrastructure/resource_groups"

  mock_outputs = {
    resource_group_name = "mockname"
  }
}

dependency "network" {
  config_path = "../../infrastructure/network"

  mock_outputs = {
    network_subnet_data_id         = "mockid"
    network_datasci_net_profile_id = "mockid"
    virtualnet_id                  = "mockid"
  }
}

dependency "storage" {
  config_path = "../../infrastructure/storage"

  mock_outputs = {
    mqtt_storage_account_name        = "mockname"
    mqtt_storage_account_primary_key = "mockkey"
    storage_share_consul_config      = "mockshare"
  }
}

dependency "datasci_nodes" {
  config_path = "../datasci_nodes"

  mock_outputs = {
    consul_server_ip = "127.0.0.1"
  }
}

dependency "eventhubs_alert" {
  config_path = "../eventhubs_alert"

  mock_outputs = {
    eventhubs_alert_topic_primary_key               = "mockkey"
    eventhubs_alert_namespace_fqn                   = "mockfqn"
    eventhubs_alert_topic_shared_access_policy_name = "mockpolicyname"
  }
}

dependency "eventhubs_mqtt" {
  config_path = "../eventhubs_mqtt"

  mock_outputs = {
    eventhubs_mqtt_topic_primary_key               = "mockkey"
    eventhubs_mqtt_namespace_fqn                   = "mockfqn"
    eventhubs_mqtt_topic_shared_access_policy_name = "mockpolicyname"
  }
}

dependency "status_monitor" {
  config_path = "../status_monitor"

  mock_outputs = {
    prometheus_ip_address = "127.0.0.1"
  }
}

terraform {
  source = "github.com/chesapeaketechnology/terraform-datasci-grafana-cluster?ref=v1.0"
}

inputs = {
  #grafana_depends_on  = "prometheus"
  #consul_share_name   = dependency.storage.outputs.storage_share_consul_config
  resource_group_name  = dependency.resource_groups.outputs.resource_group_name
  grafana_admin_user   = yamldecode(file("${find_in_parent_folders("tg_environment_inputs.yml")}"))["admin_username"]
  prometheus_server    = dependency.status_monitor.outputs.prometheus_ip_address
  consul_account_name  = dependency.storage.outputs.mqtt_storage_account_name
  consul_account_key   = dependency.storage.outputs.mqtt_storage_account_primary_key
  network_profile_id   = dependency.network.outputs.network_datasci_net_profile_id
  subnet_start_address = "10.0.1.0"
  subnet_end_address   = "10.0.1.255"
  consul_server        = dependency.datasci_nodes.outputs.consul_server_ip
  system_topic_settings = {
    topics                          = toset(yamldecode(file("${find_in_parent_folders("tg_environment_inputs.yml")}"))["alert_topics"])
    eventhub_keys                   = dependency.eventhubs_alert.outputs.eventhubs_alert_topic_primary_key
    eventhub_namespace              = dependency.eventhubs_alert.outputs.eventhubs_alert_namespace_fqn
    eventhub_shared_access_policies = dependency.eventhubs_alert.outputs.eventhubs_alert_topic_shared_access_policy_name
  }
  topic_settings = {
    topics                          = toset(yamldecode(file("${find_in_parent_folders("tg_environment_inputs.yml")}"))["mqtt_topics"])
    eventhub_keys                   = dependency.eventhubs_mqtt.outputs.eventhubs_mqtt_topic_primary_key
    eventhub_namespace              = dependency.eventhubs_mqtt.outputs.eventhubs_mqtt_namespace_fqn
    eventhub_shared_access_policies = dependency.eventhubs_mqtt.outputs.eventhubs_mqtt_topic_shared_access_policy_name
  }
}

# Temporary
generate "variables" {
  path      = "__variables.tf"
  if_exists = "overwrite_terragrunt"
  #contents  = file("tg_environment_variables.hcl")
  contents = <<EOF
variable "mqtt_topics" {
  type        = list(string)
  description = "The list of MQTT Topics to that should be pulled from the MQTT Broker and pushed into Azure Event Hubs"
  default     = ["default1", "default2"]
}
variable "mqtt_users" {
  type        = list(string)
  description = "The list of users that should be allowed connection to the MQTT Broker"
  default     = ["default1", "default2"]
}
EOF
}
