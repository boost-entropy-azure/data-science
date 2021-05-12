provider "azurerm" {
  #version = "~> 2.0"
  features {}
  disable_terraform_partner_id = true
  skip_provider_registration = true
}

data "azurerm_resource_group" "data_resource_group" {
  name = var.resource_group_name
}

resource "azurerm_postgresql_server" "data-pg" {
  name                = join("-", ["dbs", var.cluster_name, var.environment, "data"])
  location            = data.azurerm_resource_group.data_resource_group.location
  resource_group_name = data.azurerm_resource_group.data_resource_group.name

  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_password

  sku_name   = "GP_Gen5_2"
  version    = "11"
  storage_mb = 640000

  backup_retention_days        = 7
  geo_redundant_backup_enabled = true
  auto_grow_enabled            = true

  public_network_access_enabled    = true
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
  tags = var.default_tags
}

resource "azurerm_postgresql_database" "grafana-db" {
  name                = "grafana"
  resource_group_name = data.azurerm_resource_group.data_resource_group.name
  server_name         = azurerm_postgresql_server.data-pg.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

resource "azurerm_postgresql_firewall_rule" "data-fw" {
  count = length(var.allow_access_from)
  name                = join("-", ["dbfw", var.cluster_name, var.environment, "ds-data", count.index])
  resource_group_name = data.azurerm_resource_group.data_resource_group.name
  server_name         = azurerm_postgresql_server.data-pg.name
  start_ip_address    = var.allow_access_from[count.index].start_address
  end_ip_address      = var.allow_access_from[count.index].end_address
}

# Storage accounts to hold the event hub checkpoint information for the postgres connector containers that read from
# the event hub topics the grafana data integration containers are setup to use azure storage accounts currently but
# could be switched to use Kubernetes volumes instead, which would probably be better.
resource "azurerm_storage_account" "gfi_storage_account" {
  name                     = join("", ["sa", var.cluster_name, var.environment, "gfi"])
  resource_group_name      = data.azurerm_resource_group.data_resource_group.name
  location                 = data.azurerm_resource_group.data_resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "gfi_storage_container" {
  name                  = join("-", ["sc", var.cluster_name, var.environment, "gfi-checkpoint"])
  storage_account_name  = azurerm_storage_account.gfi_storage_account.name
  container_access_type = "private"
}
