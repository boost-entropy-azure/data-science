include {
  path = find_in_parent_folders()
}

#skip = true
#prevent_destroy = true

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

# Temporary until all infrastructure tasks are modules
generate "variables" {
  path      = "__variables.tf"
  if_exists = "overwrite_terragrunt"
  #contents  = file("tg_environment_variables.hcl")
  contents = <<EOF
variable "environment" {
  description = "Environment Name"
  type        = string
  default     = "OOB"
}
variable "location" {
  description = "Azure Location"
  type        = string
  default     = "eastus"
}
variable "default_tags" {
  description = "Default tags"
  type        = map(any)
  default = {
    IaC = "True"
  }
}
variable "cluster_name" {
  type        = string
  description = "Name to use for the data science culster being created"
  default     = "default"
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
