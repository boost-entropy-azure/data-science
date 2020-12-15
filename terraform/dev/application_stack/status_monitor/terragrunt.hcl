include {
  path = find_in_parent_folders()
}

dependencies {
  paths = [
    "../../infrastructure/resource_groups/",
    "../../infrastructure/network",
    "../../infrastructure/storage",
    "../datasci_nodes"
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
    network_datasci_net_profile_id = "mockid"
  }
}

dependency "storage" {
  config_path = "../../infrastructure/storage"

  mock_outputs = {
    mqtt_storage_account_name        = "mockname"
    mqtt_storage_account_primary_key = "mockkey"
  }
}

dependency "datasci_nodes" {
  config_path = "../datasci_nodes"

  mock_outputs = {
    consul_server_ip = "127.0.0.1"
  }
}

terraform {
  source = "github.com/chesapeaketechnology/terraform-datasci-modules.git//mod-azure-datasci-status-monitor?ref=v0.0.3"
}

inputs = {
  resource_group_name  = dependency.resource_groups.outputs.resource_group_name
  network_profile_id   = dependency.network.outputs.network_datasci_net_profile_id
  consul_server_ip     = dependency.datasci_nodes.outputs.consul_server_ip
  storage_account_name = dependency.storage.outputs.mqtt_storage_account_name
  storage_account_key  = dependency.storage.outputs.mqtt_storage_account_primary_key
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
