variable "admin_username" {
  type        = string
  description = "Admin user"
  default     = "datasci_admin"
}

variable "location" {
  type        = string
  description = "Region to provision resources in"
  default     = "usgovarizona"
}

variable "cluster_name" {
  type        = string
  description = "Name to use for the data science culster being created"
  default     = "datasci"
}

variable "environment" {
  type        = string
  description = "Current Environment to provision within"
  default     = "dev"
}

variable "node_count" {
  type        = number
  description = "Number of Virtual Machine nodes to provision"
  default     = 1
}

variable "default_tags" {
  type        = map(string)
  description = "Collection of default tags to apply to all resources"
}

variable "mqtt_topics" {
  type        = string
  description = "The list of MQTT Topics to that should be pulled from the MQTT Broker and pushed into Azure Event Hubs"
}
