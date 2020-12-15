include {
  path = find_in_parent_folders()
}

dependencies {
  paths = [
    "../../infrastructure/resource_groups/",
    "../../infrastructure/network",
    "../../infrastructure/storage",
    "../../infrastructure/identities",
    "../eventhubs_alert"
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
    network_public_ip_list         = ["mock1", "mock2"]
    network_public_fqdn_list       = ["mock1", "mock2"]
  }
}

dependency "storage" {
  config_path = "../../infrastructure/storage"

  mock_outputs = {
    storage_account_boot_storage_primary_blob_endpoint = "mockdata"
    container_template_deploy_name                     = "mockname"
    storage_account_facts_primary_dfs_endpoint         = "mockdata"
    storage_account_id                                 = "mockid"
    storage_share_mqtt_broker_name                     = "mockname"
    storage_share_connector_config_name                = "mockname"
    storage_share_connector_logs_name                  = "mockname"
    storage_share_consul_config_name                   = "mockname"
  }
}

dependency "identities" {
  config_path = "../../infrastructure/identities"

  mock_outputs = {
    automation_principal_appid        = "mockappid"
    automation_principal_password     = "mockpassword"
    automation_principal_tenant       = "mocktenant"
    automation_principal_subscription = "mocksub"
    automation_account_ssh_private    = "mockprivate"
    automation_account_ssh_public     = "mockpublic"
  }
}

inputs = {
  resource_group_name                                = dependency.resource_groups.outputs.resource_group_name
  network_subnet_data_id                             = dependency.network.outputs.network_subnet_data_id
  network_public_ip_list                             = dependency.network.outputs.network_public_ip_list
  network_public_fqdn_list                           = dependency.network.outputs.network_public_fqdn_list
  container_template_deploy_name                     = dependency.storage.outputs.container_template_deploy_name
  storage_account_boot_storage_primary_blob_endpoint = dependency.storage.outputs.storage_account_boot_storage_primary_blob_endpoint
  storage_account_facts_primary_dfs_endpoint         = dependency.storage.outputs.storage_account_facts_primary_dfs_endpoint
  vm_ssh_pubkey                                      = dependency.identities.outputs.automation_account_ssh_public
  vm_ssh_privkey                                     = dependency.identities.outputs.automation_account_ssh_private
  automation_principal_appid                         = dependency.identities.outputs.automation_principal_appid
  automation_principal_password                      = dependency.identities.outputs.automation_principal_password
  automation_principal_tenant                        = dependency.identities.outputs.automation_principal_tenant
  automation_principal_subscription                  = dependency.identities.outputs.automation_principal_subscription
}

terraform {
  source = "github.com/chesapeaketechnology/terraform-datasci-modules.git//mod-azure-datasci-nodes?ref=v0.0.3"
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
