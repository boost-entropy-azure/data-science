variable "workspace_id" {
    type      = string
    description = "Databricks workspace ID"
}

variable "databricks_host" {
    type      = string
    description = "Databricks host URL"
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

variable "redis_host" {
  description = "The redis hostname"
  type        = string
}

variable "redis_port" {
  description = "The redis port number"
  type        = string
}

variable "redis_secret" {
  description = "The redis connection key"
  type        = string
}

variable "azure_source_connection_string" {
  description = "The Azure eventhubs source connection string"
  type        = string
}

variable "azure_sink_connection_string" {
  description = "The Azure eventhubs sink connection string"
  type        = string
}

variable "azure_datalake_name" {
  description = "The Azure datalake name"
  type        = string
}

variable "azure_datalake_endpoint" {
  description = "The Azure datalake endpoint"
  type        = string
}


