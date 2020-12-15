# variable "location" {
#   type        = string
#   description = "Region to provision resources in"
#   default     = "eastus2"
# }

# variable "cluster_name" {
#   type        = string
#   description = "Name to use for the data science culster being created"
#   default     = "default"
# }

# variable "resource_group_name" {
#   description = "Resource Group Name"
#   type        = string
#   default     = "rgdefault"
# }

# variable "network_subnet_data_id" {
#   description = "Data Network Subnet Id"
#   type        = string
#   default     = "networkid"
# }

# variable "network_public_ip_list" {
#   description = "Public IPs"
#   type        = list(string)
#   default     = ["default1", "default2"]
# }

# variable "network_public_fqdn_list" {
#   description = "Public IP FQDNs"
#   type        = list(string)
#   default     = ["default1", "default2"]
# }

# variable "network_datasci_net_profile_id" {
#   description = "Data Network Subnet Id"
#   type        = string
#   default     = "networkprofileid"
# }

# variable "virtualnet_name" {
#   description = "Virtual Network Name"
#   type        = string
#   default     = "vnetname"
# }

# variable "consul_server_ip" {
#   description = "Primary Consul Server IP"
#   type        = string
#   default     = "127.0.0.1"
# }

# variable "storage_account_id" {
#   description = "Storage Account Id"
#   type        = string
#   default     = "storageacct"
# }

# variable "container_template_deploy_name" {
#   description = "Container Template Deployment Name"
#   type        = string
#   default     = "containername"
# }

# variable "environment" {
#   type        = string
#   description = "Current Environment to provision within"
#   default     = "dev"
# }

# variable "default_tags" {
#   type        = map(string)
#   description = "Collection of default tags to apply to all resources"
# }

# variable "admin_username" {
#   type        = string
#   description = "Admin user"
#   default     = "locadmin"
# }

# variable "node_count" {
#   type        = number
#   description = "Number of Virtual Machine nodes to provision"
#   default     = 1
# }
# variable "mqtt_topics" {
#   type        = list(string)
#   description = "The list of MQTT Topics to that should be pulled from the MQTT Broker and pushed into Azure Event Hubs"
#   default     = ["default1", "default2"]
# }

# variable "mqtt_users" {
#   type        = list(string)
#   description = "The list of users that should be allowed connection to the MQTT Broker"
#   default     = ["default1", "default2"]
# }

# variable "alert_topics" {
#   type        = list(string)
#   description = "The list of Alert Topics to that should be pulled from the MQTT Broker and pushed into Azure Event Hubs"
#   default     = ["default1", "default2"]
# }

# variable "ansible_pwfile" {
#   type        = string
#   description = "Path to file holding ansible vault password"
#   default     = "/path/to/file"
# }

# variable "grafana_admin_user" {
#   type        = string
#   description = "The username for the grafana administrative user account"
#   default     = "admin"
# }

# variable "grafana_ip" {
#   type        = string
#   description = "Grafana Server IP"
#   default     = "127.0.0.1"
# }

# variable "storage_share_mqtt_broker_name" {
#   type        = string
#   description = "Storage Shares"
#   default     = "mqtt_broker_name"
# }
# variable "storage_share_connector_config_name" {
#   type        = string
#   description = "Storage Shares"
#   default     = "connector_config_name"
# }
# variable "storage_share_connector_logs_name" {
#   type        = string
#   description = "Storage Shares"
#   default     = "connector_logs_name"
# }
# variable "storage_share_consul_config_name" {
#   type        = string
#   description = "Storage Shares"
#   default     = "consul_config_name"
# }

# variable "mqtt_storage_account_name" {
#   type        = string
#   description = "Storage Account 2 Name"
#   default     = "mqtt_storage_account_name"
# }
# variable "mqtt_storage_account_primary_key" {
#   type        = string
#   description = "Storage Account 2 Key"
#   default     = "mqtt_storage_account_primary_key"
# }

# variable "datasci_containers_mqtt_server" {
#   type        = string
#   description = "MQTT Server"
#   default     = "datasci_containers_mqtt_server"
# }

# variable "namespace_connection_string" {
#   type        = string
#   description = "MQTT Connection string"
#   default     = "namespace_connection_string"
# }

# variable "datasci_containers_group_ip_address" {
#   type        = string
#   description = "Container Group IP"
#   default     = "127.0.0.1"
# }

# variable "eventhubs_alert_topics" {
#   type        = list(string)
#   description = "EventHub Topics"
#   default     = ["default1", "default2"]
# }

# variable "eventhubs_alert_topic_primary_key" {
#   type        = list(string)
#   description = "EventHub Topic Primary Key"
#   default     = ["default1", "default2"]
# }
# variable "eventhubs_alert_namespace_fqn" {
#   type        = string
#   description = "EventHub Topic FQN"
#   default     = "FQN"
# }

# variable "eventhubs_alert_topic_shared_access_policy_name" {
#   type        = list(string)
#   description = "EventHub Topic Polcy Name"
#   default     = ["default1", "default2"]
# }

# variable "eventhubs_mqtt_topic_primary_key" {
#   type        = list(string)
#   description = "EventHub Topic Primary Key"
#   default     = ["default1", "default2"]
# }

# variable "eventhubs_mqtt_namespace_fqn" {
#   type        = string
#   description = "EventHub Topic FQN"
#   default     = "FQN"
# }

# variable "eventhubs_mqtt_topic_shared_access_policy_name" {
#   type        = list(string)
#   description = "EventHub Topic Policy Name"
#   default     = ["default1", "default2"]
# }

# variable "storage_account_boot_storage_primary_blob_endpoint" {
#   type        = string
#   description = "Primary Boot Storage"
#   default     = "default"
# }

# variable "storage_account_facts_primary_dfs_endpoint" {
#   type        = string
#   description = "Storage Account Primary DFS"
#   default     = "default"
# }

# variable "principal_pword_expiry" {
#   type        = string
#   description = "RFC3339 formated expiration date for password"
#   default     = "2099-01-01T00:00:00Z"
# }

# variable "vm_ssh_pubkey" {
#   description = "Input for SSH Public Key"
#   default     = ""
# }

# variable "vm_ssh_privkey" {
#   description = "VM SSH Private Key for Ansible"
#   type        = string
#   default     = ""
# }

# variable "automation_principal_appid" {
#   description = "Azure Access for Ansible Automation"
#   type        = string
#   default     = ""
# }
# variable "automation_principal_password" {
#   description = "Azure Access for Ansible Automation"
#   type        = string
#   default     = ""
# }
# variable "automation_principal_tenant" {
#   description = "Azure Access for Ansible Automation"
#   type        = string
#   default     = ""
# }
# variable "automation_principal_subscription" {
#   description = "Azure Access for Ansible Automation"
#   type        = string
#   default     = ""
# }

# variable "azure_cloud_domain" {
#   type        = string
#   description = "Azure cloud domain used within this cloud instance (need a way to discover this during deployment)"
#   default     = "windows.net"
# }
