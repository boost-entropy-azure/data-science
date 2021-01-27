#### Dependencies ####
# - Resource Group
# - infrastructure/network.tf
# - infrastructure/storage.tf
# - infrastructure/identities.tf
# - data.tf (pulls remote state from the above Terraform)
# - datasci_nodes.tf

module "fact-table" {
  source               = "../../modules/mod-azure-datasci-fact-table"
  resource_group_name  = var.resource_group_name
  location             = var.location
  environment          = var.environment
  admin_username       = var.admin_username
  factnode_count       = 1
  default_tags         = var.default_tags
  sub_cluster_name     = join("-", [var.cluster_name, "fact"])
  parent_subnet_id     = data.terraform_remote_state.infrastructure.outputs.network_subnet_data_id
  parent_vnetwork_name = data.terraform_remote_state.infrastructure.outputs.virtualnet_name
  consul_server        = module.datasci_nodes.consul_server_ip
  vm_ssh_pubkey        = data.terraform_remote_state.infrastructure.outputs.automation_account_ssh_public
}
