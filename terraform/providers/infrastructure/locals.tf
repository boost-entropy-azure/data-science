locals {
  remote_ips     = try(tolist(split(",", data.azurerm_key_vault_secret.azure_secret1.0.value)), [])
}
