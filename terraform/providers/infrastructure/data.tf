#### Dependencies ####
# - None

data "http" "myip" {
  count = var.source_from_vault ? 0 : 1
  url   = "http://ipecho.net/plain"
}

variable "azure_keyvault_resource_group_name" {
  description = "Azure Vault Resource Group"
  default     = "rg-vault-1"
}

variable "azure_keyvault_name" {
  description = "Azure Vault Name"
  default     = "keyvault-name"
}

variable "azure_keyvault_secret1" {
  description = "Azure Vault Secret Lookup"
  default     = "keyvault-secret1"
}

## Add Azure secrets lookup for IPs
data "azurerm_key_vault" "azure_vault" {
  count               = var.source_from_vault ? 1 : 0
  name                = var.azure_keyvault_name
  resource_group_name = var.azure_keyvault_resource_group_name
}

data "azurerm_key_vault_secret" "azure_secret1" {
  count        = var.source_from_vault ? 1 : 0
  name         = var.azure_keyvault_secret1
  key_vault_id = data.azurerm_key_vault.azure_vault.0.id
}
