variable "cluster_name" {
  type        = string
  description = "Name to use for the module cluster"
  default     = "certbot"
}

variable "admin_username" {
  type        = string
  description = "Admin user"
  default     = "certbot_admin"
}

variable "resource_group" {
  description = "Resource group to provision within"
}

variable "parent_vnetwork_name" {
  type = string
  description = "Name of the virtual network this subnet will live under"
}

variable "environment" {
  type        = string
  description = "Current Environment to provision within"
}

variable "default_tags" {
  type        = map(string)
  description = "Collection of default tags to apply to all resources"
}
