output "automation_principal_appid" {
  value = azuread_service_principal.automation_principal.application_id
}

output "automation_principal_password" {
  value = azuread_service_principal_password.principal_password.value
}

output "automation_principal_tenant" {
  value = data.azurerm_client_config.current.tenant_id
}

output "automation_principal_subscription" {
  value = data.azurerm_client_config.current.subscription_id
}

output "automation_account_ssh_private" {
  value = tls_private_key.automation_account.private_key_pem
}

output "automation_account_ssh_public" {
  value = tls_private_key.automation_account.public_key_openssh
}
