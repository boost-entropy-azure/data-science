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

variable "grafana_admin_user" {
  type        = string
  description = "The username for the grafana administrative user account"
}

variable "grafana_port" {
  type        = number
  description = "The port grafana should run on."
  default     = 3000
}

variable "network_profile_id" {
  type        = string
  description = "Name of the network profile in which to create the container"
}

variable "subnet_start_address" {
  type        = string
  description = "The starting address in the subnet cidr"
}

variable "subnet_end_address" {
  type        = string
  description = "The ending address in the subnet cidr"
}

variable "topic_settings" {
  description = "List of eventhub attributes that should be integrated into the grafana fe. The topics, keys, and policies should be aligned."
  type = object({
    topics                          = set(string)
    eventhub_keys                   = list(string)
    eventhub_namespace              = string
    eventhub_shared_access_policies = list(string)

  })
}

variable "system_topic_settings" {
  description = "List of system eventhub attributes that should be integrated into the grafana fe. The topics, keys, and policies should be aligned."
  type = object({
    topics                          = set(string)
    eventhub_keys                   = list(string)
    eventhub_namespace              = string
    eventhub_shared_access_policies = list(string)

  })
}

variable "default_tags" {
  type        = map(string)
  description = "Collection of default tags to apply to all resources"
}

variable "consul_server" {
  type        = string
  description = "IP address of a Consul server to join"
}

variable "prometheus_server" {
  type        = string
  description = "The host/IP address of Prometheus server"
}

variable "consul_account_name" {
  type        = string
  description = "The consul share storage account name"
}

variable "consul_account_key" {
  type        = string
  description = "The consul share storage account key"
}
