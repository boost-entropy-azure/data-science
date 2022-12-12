variable "resource_group_name" {
  description = "Resource group to provision within"
}

variable "location" {
  description = "Location to provision within"
}

variable "namespace_name" {
  description = "Eventhubs namespace name"
}

variable "datalake_container" {
  description = "Data lake container name"
}

variable "storage_account_id" {
  type = string
}

variable "topics" {
  type        = list(string)
  description = "List of eventhubs to create under this eventhubs space"
}

variable "listen" {
  type        = string
  description = "Listen access to the eventhub"
  default     = true
}

variable "send" {
  type        = string
  description = "Send access to the eventhub"
  default     = false
}

variable "manage" {
  type        = string
  description = "Manage access to the eventhub"
  default     = false
}

variable "default_tags" {
  type        = map(string)
  description = "Collection of default tags to apply to all resources"
}

variable "capacity" {
  type        = number
  description = "Eventhub namspace capacity"
  default     = 1
}

variable "zone_redundant"{
  type        = string
  description = "Eventhub namespace zone redundancy"
  default     = "false"
}

variable "partition_count" {
  type        = number
  description = "Eventhub topic parition count"
  default     = 2
}

variable "sku" {
  type        = string
  description = "The eventhub namespace sku"
  default      = "Standard"
}

variable "k8s_subscription_id" {
  type        = string
  description = "Separate subscription ID to use for kubernetes resources."
  default     = ""
}


