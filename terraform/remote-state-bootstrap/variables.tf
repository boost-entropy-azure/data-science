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
