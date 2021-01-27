#### Dependencies ####
# - Resource Group
# - infrastructure/network.tf
# - infrastructure/storage.tf
# - infrastructure/identities.tf
# - data.tf (pulls remote state from the above Terraform)
# - eventhubs.tf

module "datasci_nodes" {
  source                                             = "../../modules/mod-azure-datasci-nodes"
  resource_group_name                                = var.resource_group_name
  location                                           = var.location
  environment                                        = var.environment
  cluster_name                                       = var.cluster_name
  admin_username                                     = var.admin_username
  node_count                                         = var.node_count
  default_tags                                       = var.default_tags
  network_subnet_data_id                             = data.terraform_remote_state.infrastructure.outputs.network_subnet_data_id
  network_public_ip_list                             = data.terraform_remote_state.infrastructure.outputs.network_public_ip_list
  network_public_fqdn_list                           = data.terraform_remote_state.infrastructure.outputs.network_public_fqdn_list
  container_template_deploy_name                     = data.terraform_remote_state.infrastructure.outputs.container_template_deploy_name
  storage_account_boot_storage_primary_blob_endpoint = data.terraform_remote_state.infrastructure.outputs.storage_account_boot_storage_primary_blob_endpoint
  storage_account_facts_primary_dfs_endpoint         = data.terraform_remote_state.infrastructure.outputs.storage_account_facts_primary_dfs_endpoint
  vm_ssh_pubkey                                      = data.terraform_remote_state.infrastructure.outputs.automation_account_ssh_public
  vm_ssh_privkey                                     = data.terraform_remote_state.infrastructure.outputs.automation_account_ssh_private
  automation_principal_appid                         = data.terraform_remote_state.infrastructure.outputs.automation_principal_appid
  automation_principal_password                      = data.terraform_remote_state.infrastructure.outputs.automation_principal_password
  automation_principal_tenant                        = data.terraform_remote_state.infrastructure.outputs.automation_principal_tenant
  automation_principal_subscription                  = data.terraform_remote_state.infrastructure.outputs.automation_principal_subscription
}

output "datasci_node_public_ips" {
  value = module.datasci_nodes.vm_list_public
}

output "nodes_cloudinit_data" {
  value     = module.datasci_nodes.cloudinit_data
  sensitive = true
}
