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
  description = "RFC3339 formatted expiration date for password"
  default     = "2099-01-01T00:00:00Z"
}

variable "mqtt_topics" {
  type        = list(string)
  description = "The list of MQTT Topics to that should be pulled from the MQTT Broker and pushed into Azure Event Hubs"
  default     = ["default1", "default2"]
}

variable "alert_topics" {
  type        = list(string)
  description = "The list of Alert Topics pushed into Azure Event Hubs"
  default     = ["test_message"]
}

variable "network_subnet_data_id" {
  description = "Data Network Subnet Id"
  type        = string
  default     = "networkid"
}


## Remote State Vars
variable "tfstate_resource_group_name" {
  description = "Remote TF State Resource Group Name"
  type        = string
  default     = "tfstatedefault"
}

variable "remotestate_key" {
  description = "Remote state storage key"
  type        = string
  default     = "infrastructure.tfstate"
}

variable "state_container" {
  description = "Remote state storage container"
  type        = string
  default     = "remote-tfstates"
}

variable "remotestate_client_id" {
  description = "Remote state client id"
  type        = string
}

variable "remotestate_storage_account_name" {
  description = "Remote state storage_account_name"
  type        = string
  default     = "remotetfstatedata0001"
}

variable "remotestate_client_secret" {
  description = "Remote state client secret"
  type        = string
}

variable "remotestate_subscription_id" {
  description = "Remote state subscription id"
  type        = string
}

variable "remotestate_tenant_id" {
  description = "Remote state tenant id"
  type        = string
}

variable "admin_username" {
  type        = string
  description = "Admin user"
  default     = "datasci_admin"
}
