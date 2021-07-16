variable "workspace_id" {
    type      = string
    description = "Databricks workspace ID"
}

variable "cluster_name" {
    type        = string
    description = "Name to use for the data science cluster being created"
}

variable "environment" {
    type        = string
    description = "Current Environment to provision within"
}

variable "client_id" {
  description = "Remote state client id"
  type        = string
}

variable "client_secret" {
  description = "Remote state client secret"
  type        = string
}

variable "subscription_id" {
  description = "Remote state subscription id"
  type        = string
}

variable "tenant_id" {
  description = "Remote state tenant id"
  type        = string
}

