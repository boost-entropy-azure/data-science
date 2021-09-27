provider "databricks" {
  host                        = data.terraform_remote_state.infrastructure.outputs.databricks_host
  azure_workspace_resource_id = data.terraform_remote_state.infrastructure.outputs.databricks_id
  azure_client_id             = var.remotestate_client_id
  azure_client_secret         = var.remotestate_client_secret
  azure_tenant_id             = var.remotestate_tenant_id
}

provider "null" {}

module "analysis_jobs" {
    source                          = "git::https://gitlab.ctic-dev.com/engineering/dfp/analysis/analysis_jobs.git//terraform"
  
    providers                       = {
        databricks = databricks
        null       = null
    }

    jobs                            = var.jobs

    cluster_name                    = var.cluster_name
    environment                     = var.environment
    workspace_id                    = data.terraform_remote_state.infrastructure.outputs.databricks_id
    databricks_host                 = data.terraform_remote_state.infrastructure.outputs.databricks_host

    client_id                       = var.remotestate_client_id
    client_secret                   = var.remotestate_client_secret
    subscription_id                 = var.remotestate_subscription_id
    tenant_id                       = var.remotestate_tenant_id

    redis_host                      = module.analytics-cache.hostname
    redis_port                      = module.analytics-cache.port
    redis_secret                    = module.analytics-cache.secret

    azure_source_connection_string  = module.eventhubs_mqtt.namespace_connection_string
    azure_sink_connection_string    = module.eventhubs_alert.namespace_connection_string
    azure_datalake_name             = data.terraform_remote_state.infrastructure.outputs.storage_container_name
    azure_datalake_endpoint         = data.terraform_remote_state.infrastructure.outputs.storage_account_facts_primary_dfs_endpoint
}
