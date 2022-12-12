module "analytics-cache" {
  source              = "../../modules/mod-azure-datasci-redis"
  cluster_name        = var.cluster_name
  environment         = var.environment
  location            = var.location
  resource_group_name = var.resource_group_name
  connection_string   = data.terraform_remote_state.infrastructure.outputs.storage_account_connection_string
  tags                = var.default_tags
  k8s_subscription_id = var.k8s_subscription_id
}
