terraform {
  backend "azurerm" {
    storage_account_name = "abcd1234"
    container_name       = "remote-tfstates"
    key                  = "prod.terraform.tfstate"
    use_msi              = true
    subscription_id      = "00000000-0000-0000-0000-000000000000"
    tenant_id            = "00000000-0000-0000-0000-000000000000"
  }
}

### SAMPLE CLI CONFIGURATION
# terraform init \
#   -backend-config="key=${TF_VAR_environment}/terraform.tfstate" \
#   -backend-config="resource_group_name=${TF_VAR_tfstate_resource_group_name}" \
#   -backend-config="storage_account_name=${TF_VAR_environment}tfstatedata0001" \
#   -backend-config="container_name=${TF_VAR_state_container}" \
#   -backend-config="client_id=${REMOTESTATE_CLIENT_ID}" \
#   -backend-config="client_secret=${REMOTESTATE_CLIENT_SECRET}" \
#   -backend-config="subscription_id=${REMOTESTATE_SUBSCRIPTION_ID}" \
#   -backend-config="tenant_id=${REMOTESTATE_TENANT_ID}"
