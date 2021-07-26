module "cluster" {
    source               = "../../modules/mod-azure-datasci-databricks"
    cluster_name         = var.cluster_name
    environment          = var.environment
    workspace_id         = data.terraform_remote_state.infrastructure.outputs.databricks_id
    databricks_host      = data.terraform_remote_state.infrastructure.outputs.databricks_host

    client_id            = var.remotestate_client_id
    client_secret        = var.remotestate_client_secret
    subscription_id      = var.remotestate_subscription_id
    tenant_id            = var.remotestate_tenant_id

    redis_host           = module.analytics-cache.hostname
    redis_port           = module.analytics-cache.port
    redis_secret         = module.analytics-cache.secret

    azure_source_connection_string = module.eventhubs_mqtt.namespace_connection_string
    azure_sink_connection_string   = module.eventhubs_alert.namespace_connection_string
    azure_datalake_name            = data.terraform_remote_state.infrastructure.outputs.storage_container_name
    azure_datalake_endpoint        = data.terraform_remote_state.infrastructure.outputs.storage_account_facts_primary_dfs_endpoint
}