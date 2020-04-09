variable "admin_username" {
  type        = string
  description = "Admin user"
}

variable "location" {
  type        = string
  description = "Region to provision resources in"
}

variable "cluster_name" {
  type        = string
  description = "Name to use for the data science culster being created"
}

variable "environment" {
  type        = string
  description = "Current Environment to provision within"
}

variable "node_count" {
  type        = number
  description = "Number of Virtual Machine nodes to provision"
}

variable "default_tags" {
  type        = map(string)
  description = "Collection of default tags to apply to all resources"
}