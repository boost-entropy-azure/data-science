include {
  path = find_in_parent_folders()
}

dependencies {
  paths = [
    "../../infrastructure/resource_groups/",
    "../../infrastructure/network",
    "../datasci_nodes",
    "../datasci_containers",
    "../grafana"
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
    virtualnet_name = "mockid"
  }
}

dependency "datasci_nodes" {
  config_path = "../datasci_nodes"

  mock_outputs = {
    consul_server_ip = "127.0.0.1"
  }
}

dependency "datasci_containers" {
  config_path = "../datasci_containers"

  mock_outputs = {
    datasci_containers_group_ip_address = "127.0.0.1"
  }
}

dependency "grafana" {
  config_path = "../grafana"

  mock_outputs = {
    grafana_ip_address = "127.0.0.1"
  }
}

dependency "identities" {
  config_path = "../../infrastructure/identities"

  mock_outputs = {
    automation_account_ssh_public = "mockpublic"
  }
}

terraform {
  source = "github.com/chesapeaketechnology/terraform-datasci-modules.git//mod-azure-datasci-reverse-proxy?ref=v0.0.14"
}

inputs = {
  resource_group_name  = dependency.resource_groups.outputs.resource_group_name
  vm_ssh_pubkey        = dependency.identities.outputs.automation_account_ssh_public
  parent_vnetwork_name = dependency.network.outputs.virtualnet_name
  consul_server        = dependency.datasci_nodes.outputs.consul_server_ip
  mqtt_ip_address      = dependency.datasci_containers.outputs.datasci_containers_group_ip_address
  grafana_ip_address   = dependency.grafana.outputs.grafana_ip_address
}

# Temporary
# generate "variables" {
#   path      = "__variables.tf"
#   if_exists = "overwrite_terragrunt"
#   #contents  = file("tg_environment_variables.hcl")
#   contents = <<EOF
# variable "mqtt_topics" {
#   type        = list(string)
#   description = "The list of MQTT Topics to that should be pulled from the MQTT Broker and pushed into Azure Event Hubs"
#   default     = ["default1", "default2"]
# }
# variable "mqtt_users" {
#   type        = list(string)
#   description = "The list of users that should be allowed connection to the MQTT Broker"
#   default     = ["default1", "default2"]
# }
# EOF
# }
