#### Dependencies ####
# - Resource Group
# - infrastructure/network.tf
# - infrastructure/storage.tf
# - data.tf (pulls remote state from the above Terraform)
# - datasci_nodes.tf

module "status_monitor" {
  source               = "../../modules/mod-azure-datasci-status-monitor"
  resource_group_name  = var.resource_group_name
  cluster_name         = var.cluster_name
  location             = var.location
  environment          = var.environment
  default_tags         = var.default_tags
  consul_server_ip     = module.datasci_nodes.consul_server_ip
  reverse_proxy_ip     = module.reverse_proxy.reverse_proxy_private_ip
  mqtt_server_ip       = module.datasci_containers.datasci_containers_group_ip_address
  network_profile_id   = data.terraform_remote_state.infrastructure.outputs.network_datasci_net_profile_id
  storage_account_name = data.terraform_remote_state.infrastructure.outputs.mqtt_storage_account_name
  storage_account_key  = data.terraform_remote_state.infrastructure.outputs.mqtt_storage_account_primary_key
}
