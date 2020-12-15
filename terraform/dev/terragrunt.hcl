# dev/terragrunt.hcl

remote_state {
  backend = "azurerm"
  generate = {
    path      = "__backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    key                  = "${local.environment_inputs.environment}/${path_relative_to_include()}/terraform.tfstate"
    resource_group_name  = "${local.state_resource_group_name}"
    storage_account_name = "${local.state_storage_account_name}"
    container_name       = "${local.state_storage_account_container_name}"
  }
}

## DRY Inputs for each state
locals {
  environment_inputs = yamldecode(file("tg_environment_inputs.yml"))
  #local_inputs  = yamldecode(file(find_in_parent_folders("local_inputs.yml")))
  state_resource_group_name  = "${local.environment_inputs.environment}-TFStates"
  state_storage_account_name = lower(join("", [local.environment_inputs.environment, "tfstate"]))
  state_storage_account_container_name = "${local.environment_inputs.environment}-tfstates"

  admin_username = local.environment_inputs.admin_username
  #join("_", ["loc", local.environment_inputs.cluster_name, "admin"])
  default_tags = {
    Department  = "${local.environment_inputs.department}"
    PoC         = "${local.environment_inputs.poc}"
    Environment = "${local.environment_inputs.environment}"
    Cluster     = "${local.environment_inputs.cluster_name}"
    IaC_Managed = "Yes"
  }
}

#inputs = merge(local.global_inputs, local.local_inputs, {})
inputs = merge(local.environment_inputs, { default_tags = local.default_tags }, {
  admin_username = local.admin_username
})

## DRY variables throughout providers
# generate "variables" {
#   path      = "__variables.tf"
#   if_exists = "overwrite_terragrunt"
#   contents  = file("tg_environment_variables.hcl")
# }

# generate "required_providers" {
#   path      = "__required_providers_override.tf"
#   if_exists = "overwrite_terragrunt"
#   contents  = <<EOF
#     terraform {
#       required_providers {
#         azurerm = {
#           source  = "hashicorp/azurerm"
#           version = "~> 2.36.0"
#         }
#       }
#     }
# EOF
# }

generate "providers" {
  path      = "__providers_override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "azurerm" {
  features {}
  disable_terraform_partner_id = true
  skip_provider_registration   = true
}
EOF
}

terraform {
  after_hook "cleanup" {
    commands     = ["apply", "plan"]
    execute      = ["bash", "-c", "rm -fr __* .terraform.lock.hcl"]
    run_on_error = true
  }
}
