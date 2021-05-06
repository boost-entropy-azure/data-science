provider "azurerm" {
  #version = "~> 2.18.0"
  features {}
  disable_terraform_partner_id = true
  skip_provider_registration   = true
}

resource "null_resource" "grafana_dependency" {
  depends_on = [var.grafana_depends_on]
  triggers = {
    value = "${length(var.grafana_depends_on)}"
  }
}

resource "random_password" "grafana_data_password" {
  length  = 16
  special = true
}

resource "random_password" "datasci_data_password" {
  length  = 16
  special = true
}

module "grafana-data" {
  source                 = "./modules/grafana-data"
  resource_group_name    = var.resource_group_name
  cluster_name           = var.cluster_name
  environment            = var.environment
  default_tags           = var.default_tags
  location               = var.location
  administrator_login    = "grafana"
  administrator_password = random_password.grafana_data_password.result
  allow_access_from = [{
    start_address = var.subnet_start_address
    end_address   = var.subnet_end_address
    }, {
    start_address = "0.0.0.0"
    end_address   = "0.0.0.0"
  }]
}

module "datasci-data" {
  source                 = "./modules/datasci-data"
  resource_group_name    = var.resource_group_name
  cluster_name           = var.cluster_name
  environment            = var.environment
  location               = var.location
  default_tags           = var.default_tags
  administrator_login    = "postgres"
  administrator_password = random_password.datasci_data_password.result
  allow_access_from = [{
    start_address = var.subnet_start_address
    end_address   = var.subnet_end_address
    }, {
    start_address = "0.0.0.0"
    end_address   = "0.0.0.0"
  }]
}
