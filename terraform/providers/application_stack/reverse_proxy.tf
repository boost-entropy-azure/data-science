#### Dependencies ####
# - Resource Group
# - infrastructure/network.tf
# - data.tf (pulls remote state from the above Terraform)
# - datasci_nodes.tf
# - datasci_containers.tf
# - grafana.tf

module "reverse_proxy" {
  source               = "../../modules/mod-azure-datasci-reverse-proxy"
  resource_group_name  = var.resource_group_name
  cluster_name         = var.cluster_name
  location             = var.location
  environment          = var.environment
  default_tags         = var.default_tags
  admin_username       = var.admin_username
  vm_ssh_pubkey        = data.terraform_remote_state.infrastructure.outputs.automation_account_ssh_public
  parent_vnetwork_name = data.terraform_remote_state.infrastructure.outputs.virtualnet_name
  consul_server        = module.datasci_nodes.consul_server_ip
  mqtt_ip_address      = module.datasci_containers.datasci_containers_group_ip_address
  grafana_ip_address   = module.grafana.grafana_ip_address
}
