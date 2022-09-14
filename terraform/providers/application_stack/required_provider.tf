terraform {
  required_providers {
    azurerm = {
      version = "~> 2.97.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "~> 0.17.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.13.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.11.2"
    }
  }
}
