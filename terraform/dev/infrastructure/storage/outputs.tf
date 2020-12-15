output "storage_account_facts" {
  value = azurerm_storage_account.lake_storage_account
}

output "storage_account_facts_primary_dfs_endpoint" {
  value = azurerm_storage_account.lake_storage_account.primary_dfs_endpoint
}

output "storage_account_id" {
  value = azurerm_storage_account.lake_storage_account.id
}

output "storage_account_boot_storage_facts" {
  value = azurerm_storage_account.boot_storage
}

output "storage_account_boot_storage_primary_blob_endpoint" {
  value = azurerm_storage_account.boot_storage.primary_blob_endpoint
}

output "mqtt_storage_account_facts" {
  value = azurerm_storage_account.mqtt_storage_account
}

output "mqtt_storage_account_name" {
  value = azurerm_storage_account.mqtt_storage_account.name
}

output "mqtt_storage_account_primary_key" {
  value = azurerm_storage_account.mqtt_storage_account.primary_access_key
}

output "storage_share_connector_config" {
  value = azurerm_storage_share.connector_config
}

output "storage_share_connector_logs" {
  value = azurerm_storage_share.connector_logs
}

output "storage_share_consul_config" {
  value = azurerm_storage_share.consul_config
}

output "storage_share_mqtt_broker" {
  value = azurerm_storage_share.mqtt_broker
}

output "storage_share_directory_mqtt_broker" {
  value = azurerm_storage_share_directory.broker_config
}

output "container_template_deploy" {
  value = azurerm_template_deployment.datasci_container
}

output "container_template_deploy_name" {
  value = azurerm_template_deployment.datasci_container.name
}

output "storage_share_connector_config_name" {
  value = azurerm_storage_share.connector_config.name
}

output "storage_share_connector_logs_name" {
  value = azurerm_storage_share.connector_logs.name
}

output "storage_share_consul_config_name" {
  value = azurerm_storage_share.consul_config.name
}

output "storage_share_mqtt_broker_name" {
  value = azurerm_storage_share.mqtt_broker.name
}

output "storage_share_directory_mqtt_broker_name" {
  value = azurerm_storage_share_directory.broker_config.name
}
