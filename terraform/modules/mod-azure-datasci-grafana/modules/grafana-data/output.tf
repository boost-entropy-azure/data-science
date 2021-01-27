output "server_name" {
  description = "The name of the PostgreSQL server"
  value       = azurerm_postgresql_server.gdata-pg.name
}

output "server_fqdn" {
  description = "The fully qualified domain name (FQDN) of the PostgreSQL server"
  value       = azurerm_postgresql_server.gdata-pg.fqdn
}


output "server_id" {
  description = "The resource id of the PostgreSQL server"
  value       = azurerm_postgresql_server.gdata-pg.id
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
  value       = [azurerm_postgresql_firewall_rule.gdata-fw.*.id]
}
//
//output "vnet_rule_ids" {
//  description = "The list of all vnet rule resource ids"
//  value       = [azurerm_postgresql_virtual_network_rule.vnet_rules.*.id]
//}