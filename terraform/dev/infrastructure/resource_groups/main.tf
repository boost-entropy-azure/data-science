resource "azurerm_resource_group" "resource_group" {
  name     = join("-", ["rg", var.cluster_name, var.environment])
  location = var.location

  tags = var.default_tags
}
