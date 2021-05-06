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
  consul_server        = module.datasci_nodes.consul_server_ip
}
