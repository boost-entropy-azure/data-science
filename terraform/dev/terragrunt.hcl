# dev/terragrunt.hcl

remote_state {
  backend = "azurerm"
  generate = {
    path      = "__backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    key                  = "${lower(get_env("TF_VAR_environment", "dev"))}/${path_relative_to_include()}/terraform.tfstate"
    resource_group_name  = "${get_env("TF_VAR_tfstate_resource_group_name", "OOB-TFStates")}"
    storage_account_name = "${lower(get_env("TF_VAR_environment", "dev"))}tfstatedata001"
    container_name       = "${lower(get_env("TF_VAR_state_container", "remote-tfstates"))}"
    client_id            = "${get_env("REMOTESTATE_CLIENT_ID")}"
    client_secret        = "${get_env("REMOTESTATE_CLIENT_SECRET")}"
    subscription_id      = "${get_env("REMOTESTATE_SUBSCRIPTION_ID")}"
    tenant_id            = "${get_env("REMOTESTATE_TENANT_ID")}"
  }
}

## DRY Inputs for each state
locals {
  environment_inputs = yamldecode(file("tg_environment_inputs.yml"))
  admin_username     = local.environment_inputs.admin_username
  default_tags = {
    Department  = "${local.environment_inputs.department}"
    PoC         = "${local.environment_inputs.poc}"
    Environment = "${local.environment_inputs.environment}"
    Cluster     = "${local.environment_inputs.cluster_name}"
    IaC_Managed = "Yes"
  }
}

inputs = merge(
  local.environment_inputs,
  { default_tags = local.default_tags },
  { admin_username = local.admin_username }
)

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

  after_hook "cleanup2" {
    commands     = ["import", "destroy"]
    execute      = ["bash", "-c", "rm -fr __* .terraform.lock.hcl"]
    run_on_error = true
  }
}
