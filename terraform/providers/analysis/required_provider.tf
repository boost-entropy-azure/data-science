terraform {
  required_providers {
    azurerm    = {
      version = "~> 2.97.0"
    }
    databricks = {
      source  = "databrickslabs/databricks"
      version = "0.3.11"
    }
  }
}

provider "azurerm" {
  features {}
  disable_terraform_partner_id = true
  skip_provider_registration   = true
}

provider "azurerm" {
  features {}
  alias = "k8s"
  subscription_id = var.k8s_subscription_id
  disable_terraform_partner_id = true
  skip_provider_registration   = true
}
