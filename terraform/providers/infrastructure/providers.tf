terraform {
  required_providers {
    azurerm = {
      version = "~> 2.97.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "~> 0.17.0"
    }
  }
}

provider "azurerm" {
  features {}
  disable_terraform_partner_id = true
  skip_provider_registration   = true
}
