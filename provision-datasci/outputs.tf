output "grafana_server" {
  value = module.grafana.grafana_server
}

output "grafana_ip_address" {
  value = module.grafana.grafana_ip_address
}

output "grafana_admin_user" {
  value = module.grafana.grafana_admin_user
}

output "grafana_admin_password" {
  value = module.grafana.grafana_admin_password
  //  sensitive = true
}

output "grafana_url" {
  value = module.grafana.grafana_url
}

//------------

output "grafana_data_fqdn" {
  description = "The fully qualified domain name of the grafana data store"
  value = module.grafana.grafana_data_fqdn
}

output "grafana_data_database_ids" {
  description = "The list of all database resource ids"
  value = module.grafana.grafana_data_database_ids
}

output "grafana_data_login" {
  value = module.grafana.grafana_data_login
}

output "grafana_data_password" {
  value = module.grafana.grafana_data_password
  //  sensitive = true
}

//--------------------------

output "datasci_fqdn" {
  description = "The fully qualified domain name of the datasci data store"
  value = module.grafana.datasci_fqdn
}

output "datasci_database_ids" {
  description = "The list of all database resource ids"
  value = module.grafana.datasci_database_ids
}

output "datasci_login" {
  value = module.grafana.datasci_login
}

output "datasci_password" {
  value = module.grafana.datasci_password
  //  sensitive = true
}