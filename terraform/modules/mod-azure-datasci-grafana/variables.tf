variable "resource_group_name" {
  type        = string
  description = "Azure resource group in which to deploy"
}

variable "grafana_depends_on" {
  type        = string
  description = "Variable to force this module to wait on its dependencies"
}

variable "location" {
  type        = string
  description = "Region to provision resources in"
}

variable "cluster_name" {
  type        = string
  description = "Name to use for the data science cluster being created"
}

variable "environment" {
  type        = string
  description = "Current Environment to provision within"
}

variable "subnet_start_address" {
  type        = string
  description = "The starting address in the subnet cidr"
}

variable "subnet_end_address" {
  type        = string
  description = "The ending address in the subnet cidr"
}

variable "default_tags" {
  type        = map(string)
  description = "Collection of default tags to apply to all resources"
}
