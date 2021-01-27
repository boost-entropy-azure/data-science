## Useful Debug Data
output "resource_group_location" {
  value       = azurerm_resource_group.resource_group.location
  description = "Resource Group Location"
}

output "storage_account_facts" {
  value       = azurerm_storage_account.tfstate_account
  description = "Storage Account Facts"
}

## Needed data for backend.tf
output "resource_group_name" {
  value       = azurerm_resource_group.resource_group.name
  description = "Resource Group Name"
}

output "storage_account_id" {
  value       = azurerm_storage_account.tfstate_account.name
  description = "Storage Account ID"
}

output "storage_container_name" {
  value       = azurerm_storage_container.tfstate_container.name
  description = "Storage Account Principal"
}
