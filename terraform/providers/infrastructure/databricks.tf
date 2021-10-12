resource "azurerm_databricks_workspace" "analytics" {
  name                        = join("-", ["workspace", var.cluster_name, var.environment])
  resource_group_name         = var.resource_group_name
  location                    = var.location
  sku                         = "standard"
  managed_resource_group_name = join("-", [var.resource_group_name, "databricks"])
  
  tags = merge(
    var.default_tags,
    tomap({name = "fact"})
  )
}

output "databricks_host" {
  value = "https://${azurerm_databricks_workspace.analytics.workspace_url}/"
}

output "databricks_id" {
  value = azurerm_databricks_workspace.analytics.id
}