output "grafana_data_fqdn" {
  description = "The fully qualified domain name of the grafana data store"
  value       = module.grafana-data.server_fqdn
}

output "grafana_data_database_ids" {
  description = "The list of all database resource ids"
  value       = module.grafana-data.database_ids
}

output "grafana_data_login" {
  value = module.grafana-data.administrator_login
}

output "grafana_data_password" {
  value     = module.grafana-data.administrator_password
  sensitive = true
}

//--------------------------

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
