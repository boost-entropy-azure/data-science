terraform {
  required_providers {
    azurerm = {
      version = "~> 2.34.0"
    }
    databricks = {
      source  = "databrickslabs/databricks"
      version = "0.3.6"
    }
  }
}
