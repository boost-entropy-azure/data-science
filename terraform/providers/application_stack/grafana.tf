#### Dependencies ####
# - Resource Group
# - infrastructure/network.tf
# - infrastructure/storage.tf
# - data.tf (pulls remote state from the above Terraform)
# - datasci_nodes.tf
# - eventhubs.tf
# - status_monitor.tf

module "grafana" {
  source               = "../../modules/mod-azure-datasci-grafana"
  grafana_depends_on   = "prometheus"
  resource_group_name  = var.resource_group_name
  cluster_name         = var.cluster_name
  location             = var.location
  environment          = var.environment
  default_tags         = var.default_tags
  subnet_start_address = "10.0.1.0"
  subnet_end_address   = "10.0.1.255"
}

output "postgres_data_fqdn" {
  description = "The postgres fqdn the data database"
  value       = module.grafana.datasci_fqdn
}

output "postgres_data_administrator_username" {
  description = "The postgres administrator username for the data database"
  value       = module.grafana.datasci_login
}

output "postgres_data_administrator_password" {
  description = "The postgres administrator password for the data database"
  value       = module.grafana.datasci_password
  sensitive   = true
}

//------------- Event Hub Checkpoint Container Information -------------

output "gfi_storage_account_connection_string" {
  description = "The connection string for the postgres connector checkpoint storage account"
  value       = module.grafana.gfi_storage_account_connection_string
  sensitive   = true
}

output "gfi_storage_container_name" {
  description = "The storage container name for the postgres connector checkpoint"
  value       = module.grafana.gfi_storage_container_name
}