variable "tfstate_resource_group_name" {
  description = "Resource Group Name"
  type        = string
  default     = "OOB-TFStates"
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
    Department = "Monkey"
    PoC        = "LiveStream"
  }
}

variable "storageacct_kind" {
  description = "Storage Account Kind"
  type        = string
  default     = "StorageV2"
}

variable "storageacct_tier" {
  description = "Storage Account Tier"
  type        = string
  default     = "Standard"
}

variable "storageacct_repl" {
  description = "Storage Account Replication type"
  type        = string
  default     = "GRS"
}

variable "blob_retention" {
  description = "Blob Storage Retention"
  type        = number
  default     = 30
}

variable "remotestate_storage_account_name" {
  description = "Remote state storage_account_name"
  type        = string
  default     = "remotetfstatedata0001"
}