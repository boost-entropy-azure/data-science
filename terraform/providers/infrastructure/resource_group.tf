#### Dependencies ####
# - None

resource "azurerm_resource_group" "resource_group" {
  count    = var.manage_resource_group ? 1 : 0
  name     = join("-", ["rg", var.cluster_name, var.environment])
  location = var.location
  lifecycle {
    prevent_destroy = true
  }

  tags = var.default_tags
}

output "resource_group_name" {
  depends_on = [
    azurerm_resource_group.resource_group,
  ]
  value = azurerm_resource_group.resource_group.*.name
}
