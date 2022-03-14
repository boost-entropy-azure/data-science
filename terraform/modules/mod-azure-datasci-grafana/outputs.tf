output "datasci_server_name" {
  description = "The name of the datasci data store"
  value       = module.datasci-data.server_name
}

output "datasci_fqdn" {
  description = "The fully qualified domain name of the datasci data store"
  value       = module.datasci-data.server_fqdn
}

output "datasci_database_ids" {
  description = "The list of all database resource ids"
  value       = module.datasci-data.database_ids
}

output "datasci_login" {
  value = module.datasci-data.administrator_login
}

output "datasci_password" {
  value     = module.datasci-data.administrator_password
  sensitive = true
}

//--------------------------

output "gfi_storage_account_connection_string" {
  description = "The connection string for the postgres connector checkpoint storage account"
  value       = module.datasci-data.gfi_storage_account_connection_string
  sensitive   = true
}

output "gfi_storage_container_name" {
  description = "The storage container name for the postgres connector checkpoint"
  value       = module.datasci-data.gfi_storage_container_name
}
