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

variable "manage_virtual_network" {
  description = "Manage the virtual network"
  type        = bool
  default     = true
}
variable "virtual_network_name" {
  description = "Virtual Network Name"
  type        = string
  default     = "default-vnet"
}

variable "manage_subnet" {
  description = "Manage the subnet within the virtual network"
  type        = bool
  default     = true
}

variable "subnet_name" {
  description = "Subnet Name"
  type        = string
  default     = "default-snet"
}

variable "manage_aks_cluster" {
  description = "Manage the AKS cluster"
  type        = bool
  default     = true
}

variable "aks_cluster_name" {
  description = "AKS cluster Name"
  type        = string
  default     = "default-aks"
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
  default     = {
    IaC = "True"
  }
}

variable "cluster_name" {
  type        = string
  description = "Name to use for the data science cluster being created"
  default     = "default"
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

variable "aks_api_server_authorized_ip_ranges" {
  type        = set(string)
  description = "A set of CIDR range strings (e.g. 127.117.106.90/29) given access to the Kubernetes cluster API Server (e.g. used by kubectl)."
  default     = []
}

variable "k8s_subscription_id" {
  type        = string
  description = "Separate subscription ID to use for kubernetes resources."
  default     = ""
}

variable "remotestate_client_id" {
  description = "Remote state client id"
  type        = string
}

variable "remotestate_client_secret" {
  description = "Remote state client secret"
  type        = string
}
