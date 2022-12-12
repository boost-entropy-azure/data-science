terraform {
  required_providers {
    azurerm = {
      version = "~> 3.21.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.k8s_subscription_id
  disable_terraform_partner_id = true
  skip_provider_registration   = true
}

provider "azurerm" {
  features {}
  alias                        = "k8s"
  subscription_id              = var.k8s_subscription_id
  disable_terraform_partner_id = true
  skip_provider_registration   = true
}
