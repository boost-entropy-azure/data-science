terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
  required_version = ">= 0.13"
}

provider "azurerm" {
  features {}
  disable_terraform_partner_id = true
  skip_provider_registration   = true
}

resource "azurerm_resource_group" "resource_group" {
  name     = var.tfstate_resource_group_name
  location = var.location

  tags = merge(
    var.default_tags,
    {
      "IaC_Managed" = "Yes",
    }
  )

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_storage_account" "tfstate_account" {
  name                     = substr(lower(var.remotestate_storage_account_name), 0, 23)
  resource_group_name      = azurerm_resource_group.resource_group.name
  location                 = azurerm_resource_group.resource_group.location
  account_kind             = var.storageacct_kind
  account_tier             = var.storageacct_tier
  account_replication_type = var.storageacct_repl

  enable_https_traffic_only = true
  allow_blob_public_access  = false
  min_tls_version           = "TLS1_2" #not supported in GovCloud
  blob_properties {
    delete_retention_policy {
      days = var.blob_retention
    }
  }
  tags = merge(
    var.default_tags,
    {
      "IaC_Managed" = "Yes",
      "Purpose"     = "Terraform State"
    }
  )
}

resource "azurerm_storage_container" "tfstate_container" {
  #name = lower(join("-", [var.environment, "tfstates"]))
  name                 = "remote-tfstates"
  storage_account_name = azurerm_storage_account.tfstate_account.name
}
