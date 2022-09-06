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
