include {
  path = find_in_parent_folders()
}

dependencies {
  paths = [
    "../../infrastructure/resource_groups/",
    "../../infrastructure/storage"
  ]
}

dependency "resource_groups" {
  config_path = "../../infrastructure/resource_groups"

  mock_outputs = {
    resource_group_name = "mockname"
  }
}

dependency "storage" {
  config_path = "../../infrastructure/storage"

  mock_outputs = {
    container_template_deploy_name = "mockname"
    storage_account_id             = "mockid"
  }
}

terraform {
  source = "github.com/chesapeaketechnology/terraform-datasci-modules.git//mod-azure-datasci-eventhubs?ref=v0.0.3"
}

locals {
  topics = toset(list("alert_message"))
}

inputs = {
  resource_group_name = dependency.resource_groups.outputs.resource_group_name
  datalake_container  = dependency.storage.outputs.container_template_deploy_name
  storage_account_id  = dependency.storage.outputs.storage_account_id
  namespace_name      = join("-", [yamldecode(file("${find_in_parent_folders("tg_environment_inputs.yml")}"))["cluster_name"], yamldecode(file("${find_in_parent_folders("tg_environment_inputs.yml")}"))["environment"], "alert-eventhubs"])
  topics              = toset(list("alert_message"))

}

generate "outputs" {
  path      = "__outputs.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
output "eventhubs_alert_topic_primary_key" {
  value = values(azurerm_eventhub_authorization_rule.eventhub_auth_rule)[*].primary_key
}

output "eventhubs_alert_namespace_fqn" {
  value = element(split("/", element(split(";", azurerm_eventhub_namespace.eventhubs.default_primary_connection_string), 0)), 2)
}

output "eventhubs_alert_topic_shared_access_policy_name" {
  value = values(azurerm_eventhub_authorization_rule.eventhub_auth_rule)[*].name
}
EOF
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
