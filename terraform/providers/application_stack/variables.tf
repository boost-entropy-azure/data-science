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
  description = "RFC3339 formatted expiration date for password"
  default     = "2099-01-01T00:00:00Z"
}

variable "mqtt_topics" {
  type        = list(string)
  description = "The list of MQTT Topics to that should be pulled from the MQTT Broker and pushed into Azure Event Hubs"
  default     = [
    "gsm_message", "cdma_message", "umts_message", "lte_message", "nr_message", "80211_beacon_message",
    "bluetooth_message", "gnss_message", "device_status_message", "cellular_ota_message"
  ]
}

variable "alert_topics" {
  type        = list(string)
  description = "The list of Alert Topics pushed into Azure Event Hubs"
  default     = ["alert_message"]
}

variable "event_topics" {
  type        = list(string)
  description = "The list of Events coming from EventGrid pushed into Azure Event Hubs"
  default     = ["photo_message"]
}

variable "network_subnet_data_id" {
  description = "Data Network Subnet Id"
  type        = string
  default     = "networkid"
}


## Remote State Vars
variable "tfstate_resource_group_name" {
  description = "Remote TF State Resource Group Name"
  type        = string
  default     = "tfstatedefault"
}

variable "remotestate_key" {
  description = "Remote state storage key"
  type        = string
  default     = "infrastructure.tfstate"
}

variable "state_container" {
  description = "Remote state storage container"
  type        = string
  default     = "remote-tfstates"
}

variable "remotestate_client_id" {
  description = "Remote state client id"
  type        = string
}

variable "remotestate_storage_account_name" {
  description = "Remote state storage_account_name"
  type        = string
  default     = "remotetfstatedata0001"
}

variable "remotestate_client_secret" {
  description = "Remote state client secret"
  type        = string
}

variable "remotestate_subscription_id" {
  description = "Remote state subscription id"
  type        = string
}

variable "remotestate_tenant_id" {
  description = "Remote state tenant id"
  type        = string
}

variable "admin_username" {
  type        = string
  description = "Admin user"
  default     = "datasci_admin"
}

variable "postgres_admin_password" {
  type        = string
  description = "The Password associated with the administrator_login for the PostgreSQL database."
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

variable "flux_image_pull_secrets" {
  type        = string
  description = "Kubernetes secret name used for pulling the toolkit images from a private registry."
}

variable "gitlab_token" {
  type        = string
  description = "The GitLab token which will be used to authenticate when pulling from the Flux/Fleet-infra repository"
}