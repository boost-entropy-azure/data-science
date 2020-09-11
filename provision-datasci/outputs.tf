output "grafana_endpoint" {
  value = "https://${module.reverse_proxy.reverse_proxy_fqdn}"
}

output "grafana_admin_user" {
  value = module.grafana.grafana_admin_user
}

output "grafana_admin_password" {
  value = module.grafana.grafana_admin_password.result
  //  sensitive = true
}

output "grafana_datasource_host" {
  description = "The fully qualified domain name of the datasci data store"
  value = "${module.grafana.datasci_fqdn}:5432"
}

output "grafana_datasource_db_names" {
  description = "The list of all database resource ids"
  value = module.grafana.datasci_database_ids
}

output "grafana_datasource_login" {
  value = "${module.grafana.datasci_login}@${module.grafana.datasci_fqdn}"
}

output "grafana_datasource_password" {
  value = module.grafana.datasci_password
  //  sensitive = true
}