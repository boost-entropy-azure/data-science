provider "azurerm" {
  features {}
}

resource "azurerm_redis_cache" "analytics" {
  name                = join("-", [var.cluster_name, var.environment, "cache"])
  location            = var.location
  resource_group_name = var.resource_group_name
  capacity            = 1
  family              = "P"
  sku_name            = "Premium"
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"
  tags                = var.tags

  redis_configuration {
      rdb_backup_enabled            = true
      rdb_backup_frequency          = 60 # 60 minutes
      rdb_storage_connection_string = var.connection_string
  }
}