output "server_name" {
  description = "The name of the PostgreSQL server"
  value       = azurerm_postgresql_server.data-pg.name
}

output "server_fqdn" {
  description = "The fully qualified domain name (FQDN) of the PostgreSQL server"
  value       = azurerm_postgresql_server.data-pg.fqdn
}


output "server_id" {
  description = "The resource id of the PostgreSQL server"
  value       = azurerm_postgresql_server.data-pg.id
}

output "administrator_login" {
  value = var.administrator_login
}

output "administrator_password" {
  value     = var.administrator_password
  sensitive = true
}

output "database_ids" {
  description = "The list of all database resource ids"
  value       = [azurerm_postgresql_database.grafana-db.*.id]
}

output "firewall_rule_ids" {
  description = "The list of all firewall rule resource ids"
  value       = [azurerm_postgresql_firewall_rule.data-fw.*.id]
}

output "gfi_storage_account_connection_string" {
  description = "The connection string for the postgres connector checkpoint storage account"
  value       = azurerm_storage_account.gfi_storage_account.primary_blob_connection_string
  sensitive = true
}

output "gfi_storage_container_name" {
  description = "The storage container name for the postgres connector checkpoint"
  value       = azurerm_storage_container.gfi_storage_container.name
}
