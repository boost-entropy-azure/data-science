provider "azuread" {
  version = "~> 1.0.0"
}

data "azurerm_client_config" "current" {
}

resource "random_password" "password" {
  length           = 32
  special          = true
  override_special = "=_."
}

resource "azuread_application" "automation_access" {
  name = join(".", ["svc", var.resource_group_name, "automation"])
}

resource "azuread_service_principal" "automation_principal" {
  application_id = azuread_application.automation_access.application_id
}

resource "azuread_service_principal_password" "principal_password" {
  service_principal_id = azuread_service_principal.automation_principal.id
  value                = random_password.password.result
  end_date             = var.principal_pword_expiry
}

# TODO: implement restricted service account controls
resource "azurerm_role_assignment" "automation_principal" {
  scope              = "${join("/", ["/subscriptions", data.azurerm_client_config.current.subscription_id, "resourceGroups", var.resource_group_name])}"
  role_definition_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c" #"Contributor"
  principal_id       = "${azuread_service_principal.automation_principal.object_id}"
}

resource "tls_private_key" "automation_account" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
