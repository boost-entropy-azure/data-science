include {
  path = find_in_parent_folders()
}

dependencies {
  paths = [
    "../../infrastructure/resource_groups/",
    "../../infrastructure/network",
    "../../infrastructure/storage",
    "../datasci_nodes",
    "../eventhubs_mqtt"
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
  }
}

dependency "storage" {
  config_path = "../../infrastructure/storage"

  mock_outputs = {
    container_template_deploy_name      = "mockname"
    storage_account_id                  = "mockid"
    storage_share_mqtt_broker_name      = "mockname"
    storage_share_connector_config_name = "mockname"
    storage_share_connector_logs_name   = "mockname"
    storage_share_consul_config_name    = "mockname"
    mqtt_storage_account_name           = "mockname"
    mqtt_storage_account_primary_key    = "mockkey"
  }
}

dependency "datasci_nodes" {
  config_path = "../datasci_nodes"

  mock_outputs = {
    consul_server_ip = "127.0.0.1"
  }
}

dependency "eventhubs_mqtt" {
  config_path = "../eventhubs_mqtt"

  mock_outputs = {
    eventhubs_mqtt_namespace_connection_string = "mockmqttnamespace"
  }
}

terraform {
  source = "github.com/chesapeaketechnology/terraform-datasci-modules.git//mod-azure-datasci-containers?ref=v0.0.3"
}


inputs = {
  resource_group_name            = dependency.resource_groups.outputs.resource_group_name
  network_subnet_data_id         = dependency.network.outputs.network_subnet_data_id
  container_template_deploy_name = dependency.storage.outputs.container_template_deploy_name
  storage_account_id             = dependency.storage.outputs.storage_account_id
  network_profile_id             = dependency.network.outputs.network_datasci_net_profile_id
  share_name_mqtt                = dependency.storage.outputs.storage_share_mqtt_broker_name
  share_name_connector_config    = dependency.storage.outputs.storage_share_connector_config_name
  share_name_connector_log       = dependency.storage.outputs.storage_share_connector_logs_name
  share_name_mqttconsulgateway   = dependency.storage.outputs.storage_share_consul_config_name
  volume_storage_account_name    = dependency.storage.outputs.mqtt_storage_account_name
  volume_storage_account_key     = dependency.storage.outputs.mqtt_storage_account_primary_key
  #
  mqtt_broker_share_name      = dependency.storage.outputs.storage_share_mqtt_broker_name
  mqtt_config_share_name      = dependency.storage.outputs.storage_share_connector_config_name
  consul_config_share_name    = dependency.storage.outputs.storage_share_consul_config_name
  storage_account_name        = dependency.storage.outputs.mqtt_storage_account_name
  storage_account_key         = dependency.storage.outputs.mqtt_storage_account_primary_key
  consul_server               = dependency.datasci_nodes.outputs.consul_server_ip
  namespace_connection_string = dependency.eventhubs_mqtt.outputs.eventhubs_mqtt_namespace_connection_string
  mqtt_admin                  = yamldecode(file("${find_in_parent_folders("tg_environment_inputs.yml")}"))["admin_username"]
  mqtt_topics                 = yamldecode(file("${find_in_parent_folders("tg_environment_inputs.yml")}"))["mqtt_topics"]
  mqtt_eventhubs_batch_size   = "10"
  mqtt_scheduled_interval     = "500"
}
