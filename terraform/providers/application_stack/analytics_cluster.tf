module "cluster" {
    source       = "../../modules/mod-azure-datasci-databricks"
    workspace_id = data.terraform_remote_state.infrastructure.outputs.databricks_id
    cluster_name = var.cluster_name
    environment  = var.environment
}