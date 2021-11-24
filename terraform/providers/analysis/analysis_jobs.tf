provider "databricks" {
  host                = azurerm_databricks_workspace.analytics.workspace_url
  azure_client_id     = var.remotestate_client_id
  azure_client_secret = var.remotestate_client_secret
  azure_tenant_id     = var.remotestate_tenant_id
}

module "analysis_jobs" {
  depends_on = [azurerm_databricks_workspace.analytics] // Needed so that the auth can work as expected because it uses the workspace ID
  source     = "git::https://gitlab.ctic-dev.com/engineering/dfp/analysis/analysis_jobs.git//terraform"

  providers = {
    databricks = databricks
  }

  jobs = var.jobs

  cluster_name    = var.cluster_name
  environment     = var.environment
  workspace_id    = azurerm_databricks_workspace.analytics.id
  databricks_host = "https://${azurerm_databricks_workspace.analytics.workspace_url}/"

  client_id       = var.remotestate_client_id
  client_secret   = var.remotestate_client_secret
  subscription_id = var.remotestate_subscription_id
  tenant_id       = var.remotestate_tenant_id

  redis_host   = module.analytics-cache.hostname
  redis_port   = module.analytics-cache.port
  redis_secret = module.analytics-cache.secret

  azure_source_connection_string = data.terraform_remote_state.application.outputs.eventhubs_mqtt_namespace_connection_string
  azure_sink_connection_string   = data.terraform_remote_state.application.outputs.eventhubs_alert_namespace_connection_string
  azure_datalake_name            = data.terraform_remote_state.infrastructure.outputs.storage_container_name
  azure_datalake_endpoint        = data.terraform_remote_state.infrastructure.outputs.storage_account_facts_primary_dfs_endpoint
}
