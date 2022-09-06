variable "manage_resource_group" {
  description = "Manage the resource Group"
  type        = bool
  default     = true
}
variable "resource_group_name" {
  description = "Resource Group Name"
  type        = string
  default     = "rgdefault"
}

variable "environment" {
  description = "Environment Name"
  type        = string
  default     = "OOB"
}

variable "location" {
  description = "Azure Location"
  type        = string
  default     = "eastus"
}

variable "default_tags" {
  description = "Default tags"
  type        = map(any)
  default     = {
    IaC = "True"
  }
}

variable "cluster_name" {
  type        = string
  description = "Name to use for the data science cluster being created"
  default     = "default"
}

variable "sp_password" {
  type        = string
  description = "Azure Service Principal Cred"
  default     = "000-000-000-000"
}

variable "principal_pword_expiry" {
  type        = string
  description = "RFC3339 formated expiration date for password"
  default     = "2099-01-01T00:00:00Z"
}

variable "mqtt_topics" {
  type        = list(string)
  description = "The list of MQTT Topics to that should be pulled from the MQTT Broker and pushed into Azure Event Hubs"
  default     = ["default1", "default2"]
}

variable "network_subnet_data_id" {
  description = "Data Network Subnet Id"
  type        = string
  default     = "networkid"
}

variable "source_from_vault" {
  type        = bool
  description = "Pull source information from Azure Vault"
  default     = false
}

variable "aks_api_server_authorized_ip_ranges" {
  type        = set(string)
  description = "A set of CIDR range strings (e.g. 127.117.106.90/29) given access to the Kubernetes cluster API Server (e.g. used by kubectl)."
  default     = []
}

variable "flux_target_path" {
  type        = string
  description = "Relative path to the Git repository root where Flux manifests are committed."
}

variable "flux_repo_branch" {
  type        = string
  description = "Branch of the Git repository where Flux should sync."
}

variable "flux_repo_url" {
  type        = string
  description = "URL of the Git repository that Flux should sync."
}

variable "harbor_registry" {
  type        = string
  description = "Container registry where the charts and images are published."
}

variable "flux_image_pull_secrets" {
  type        = string
  description = "Kubernetes secret name used for pulling the toolkit images from a private registry."
}