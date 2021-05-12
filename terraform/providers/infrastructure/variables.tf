
variable "manage_resource_group" {
  description = "Manage the resource Group"
  type        = bool
  default     = true
}
variable "resource_group_name" {
  description = "Resource Group Name"
  type        = string
  default     = "rgdefault"
}

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
  description = "Name to use for the data science cluster being created"
  default     = "default"
}

variable "node_count" {
  type        = number
  description = "Number of Virtual Machine nodes to provision"
  default     = 3
}

variable "sp_password" {
  type        = string
  description = "Azure Service Principal Cred"
  default     = "000-000-000-000"
}

variable "principal_pword_expiry" {
  type        = string
  description = "RFC3339 formated expiration date for password"
  default     = "2099-01-01T00:00:00Z"
}

variable "mqtt_topics" {
  type        = list(string)
  description = "The list of MQTT Topics to that should be pulled from the MQTT Broker and pushed into Azure Event Hubs"
  default     = ["default1", "default2"]
}

variable "network_subnet_data_id" {
  description = "Data Network Subnet Id"
  type        = string
  default     = "networkid"
}

variable "source_from_vault" {
  type        = bool
  description = "Pull source information from Azure Vault"
  default     = false
}
