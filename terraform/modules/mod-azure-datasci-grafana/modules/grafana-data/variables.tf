variable "resource_group_name" {
  type        = string
  description = "Azure resource group in which to deploy"
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

variable "default_tags" {
  type        = map(string)
  description = "Collection of default tags to apply to all resources"
}

variable "administrator_login" {
  description = "The Administrator Login for the data store"
}

variable "administrator_password" {
  description = "The Password associated with the administrator_login for the data store"
}

variable "allow_access_from" {
  type = list(object({
    start_address = string
    end_address = string
  }))
  description = "A list of ip ranges allowed to access the database"
}