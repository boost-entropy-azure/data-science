variable "sub_cluster_name" {
  type        = string
  description = "Name to use for the module sub-cluster"
  default     = "fact"
}

variable "node_count" {
  type        = number
  description = "Number of Virtual Machine nodes to provision"
  default     = 1
}

variable "admin_username" {
  type        = string
  description = "Admin user"
  default     = "datasci_admin"
}

variable "resource_group" {
  description = "Resource group to provision within"
}

variable "parent_vnetwork_name" {
  type        = string
  description = "Name of the virtual network this subnet will live under"
}

variable "parent_subnet_id" {
  type        = string
  description = "ID of the parent subnet"
}

variable "environment" {
  type        = string
  description = "Current Environment to provision within"
}

variable "default_tags" {
  type        = map(string)
  description = "Collection of default tags to apply to all resources"
}

variable "nodes" {
  default     = ""
  description = "List of hosts in play"
}
