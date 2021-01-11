provider "azurerm" {
  #version = "~> 2.0"
  features {}
  disable_terraform_partner_id = true
  skip_provider_registration = true
}

data "azurerm_resource_group" "gdata_resource_group" {
  name = var.resource_group_name
}

resource "azurerm_postgresql_server" "gdata-pg" {
  name                = join("-", ["dbs", var.cluster_name, var.environment, "grafana-config-data"])
  location            = data.azurerm_resource_group.gdata_resource_group.location
  resource_group_name = data.azurerm_resource_group.gdata_resource_group.name

  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_password

  sku_name   = "GP_Gen5_2"
  version    = "11"
  storage_mb = 204800

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
  resource_group_name = data.azurerm_resource_group.gdata_resource_group.name
  server_name         = azurerm_postgresql_server.gdata-pg.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

resource "azurerm_postgresql_firewall_rule" "gdata-fw" {
  count = length(var.allow_access_from)
  name                = join("-", ["dbfw", var.cluster_name, var.environment, "grafana-data", count.index])
  resource_group_name = data.azurerm_resource_group.gdata_resource_group.name
  server_name         = azurerm_postgresql_server.gdata-pg.name
  start_ip_address    = var.allow_access_from[count.index].start_address
  end_ip_address      = var.allow_access_from[count.index].end_address
}
