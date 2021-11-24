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

variable "cluster_name" {
  type        = string
  description = "Name to use for the data science cluster being created"
  default     = "default"
}

variable "location" {
  description = "Azure Location"
  type        = string
  default     = "eastus"
}

variable "jobs" {
  type        = list(string)
  description = "The list of Spark jobs"
  default     = ["default1", "default2"]
}

variable "default_tags" {
  description = "Default tags"
  type        = map(any)
  default     = {
    IaC = "True"
  }
}


# These remote state variables are a bit of a misnomer as we are using them for more than just remote state
variable "remotestate_client_id" {
  description = "Remote state client id"
  type        = string
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


## Remote State Vars
variable "tfstate_resource_group_name" {
  description = "Remote TF State Resource Group Name"
  type        = string
  default     = "tfstatedefault"
}

variable "remotestate_storage_account_name" {
  description = "Remote state storage_account_name"
  type        = string
  default     = "remotetfstatedata0001"
}

variable "state_container" {
  description = "Remote state storage container"
  type        = string
  default     = "remote-tfstates"
}

variable "infrastructure_remotestate_key" {
  description = "Remote state storage key for the infrastructure resources"
  type        = string
  default     = "infrastructure.tfstate"
}

variable "application_remotestate_key" {
  description = "Remote state storage key for the application stack resources"
  type        = string
  default     = "application_stack.tfstate"
}