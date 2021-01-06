include {
  path = find_in_parent_folders()
}

dependencies {
  paths = [
    "../../infrastructure/resource_groups/",
    "../../infrastructure/network",
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
    network_subnet_data_id = "mockid"
    virtualnet_name        = "mockvnet"
  }
}

dependency "datasci_nodes" {
  config_path = "../datasci_nodes"

  mock_outputs = {
    consul_server_ip = "127.0.0.1"
  }
}

dependency "identities" {
  config_path = "../../infrastructure/identities"

  mock_outputs = {
    automation_account_ssh_public = "mockpublic"
  }
}

terraform {
  #source = "../../../../../terraform-datasci-modules/mod-azure-datasci-fact-table"
  source = "github.com/chesapeaketechnology/terraform-datasci-modules.git//mod-azure-datasci-fact-table?ref=v0.0.15"
}

locals {
  sub_cluster = join("-", [local.burrito, "fact"])

  burrito = yamldecode(file("${find_in_parent_folders("tg_environment_inputs.yml")}"))["cluster_name"]
  #taco    = lower(get_env("TF_VAR_environment", "dev"))

}


inputs = {
  resource_group_name  = dependency.resource_groups.outputs.resource_group_name
  sub_cluster_name     = local.sub_cluster
  parent_subnet_id     = dependency.network.outputs.network_subnet_data_id
  parent_vnetwork_name = dependency.network.outputs.virtualnet_name
  consul_server        = dependency.datasci_nodes.outputs.consul_server_ip
  vm_ssh_pubkey        = dependency.identities.outputs.automation_account_ssh_public
}

# # Temporary
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
