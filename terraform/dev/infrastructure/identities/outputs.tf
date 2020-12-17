output "automation_principal_appid" {
  #value = azuread_service_principal.automation_principal.application_id
  value     = data.azuread_service_principal.current.application_id
  sensitive = true
}

output "automation_principal_password" {
  #value = azuread_service_principal_password.principal_password.value
  value     = var.sp_password
  sensitive = true
}

output "automation_principal_tenant" {
  value     = data.azurerm_client_config.current.tenant_id
  sensitive = true
}

output "automation_principal_subscription" {
  value     = data.azurerm_client_config.current.subscription_id
  sensitive = true
}

output "automation_account_ssh_private" {
  value     = tls_private_key.automation_account.private_key_pem
  sensitive = true
}

output "automation_account_ssh_public" {
  value     = tls_private_key.automation_account.public_key_openssh
  sensitive = true
}
