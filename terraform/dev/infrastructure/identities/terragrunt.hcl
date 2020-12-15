include {
  path = find_in_parent_folders()
}

dependencies {
  paths = [
    find_in_parent_folders("resource_groups")
  ]
}

dependency "resource_groups" {
  config_path = find_in_parent_folders("resource_groups")

  mock_outputs = {
    resource_group_name = "mockname"
  }
}

inputs = {
  resource_group_name = dependency.resource_groups.outputs.resource_group_name
}

generate "required_provider" {
  path      = "__required_provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    azurerm = {
      version = "~> 2.34.0"
    }
  }
}
EOF
}

# terraform {
#   after_hook "drop_pubkey" {
#     commands     = ["apply"]
#     execute      = ["bash", "-c", "terraform output automation_account_ssh_private 2>/dev/null > ~/.ssh/datasci_terragrunt_key"]
#     run_on_error = false
#   }
#   after_hook "chmod_pubkey" {
#     commands     = ["apply"]
#     execute      = ["bash", "-c", "chmod 600 ~/.ssh/datasci_terragrunt_key"]
#     run_on_error = false
#   }
# }

# Temporary until all infrastructure tasks are modules
generate "variables" {
  path      = "__variables.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
variable "resource_group_name" {
  description = "Resource Group Name"
  type        = string
  default     = "rgdefault"
}
variable "principal_pword_expiry" {
  type        = string
  description = "RFC3339 formated expiration date for password"
  default     = "2099-01-01T00:00:00Z"
}
variable "default_tags" {
  description = "Default tags"
  type        = map(any)
  default = {
    IaC = "True"
  }
}
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
