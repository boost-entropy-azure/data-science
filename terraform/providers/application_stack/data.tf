data "terraform_remote_state" "infrastructure" {
  backend = "azurerm"

  config = {
    key                  = "${var.environment}/${var.remotestate_key}"
    resource_group_name  = var.tfstate_resource_group_name
    storage_account_name = var.remotestate_storage_account_name
    container_name       = var.state_container
    client_id            = var.remotestate_client_id
    client_secret        = var.remotestate_client_secret
    subscription_id      = var.remotestate_subscription_id
    tenant_id            = var.remotestate_tenant_id
  }
}

# =========================== FLUX CD ===========================
data "flux_install" "main" {
  target_path        = var.flux_target_path
  registry           = var.flux_harbor_registry
  image_pull_secrets = var.flux_image_pull_secrets
}

data "flux_sync" "main" {
  target_path = var.flux_target_path
  url         = var.flux_repo_url
  branch      = var.flux_repo_branch
}

data "kubectl_file_documents" "install" {
  content = data.flux_install.main.content
}

data "kubectl_file_documents" "sync" {
  content = data.flux_sync.main.content
}

locals {
  install = [for v in data.kubectl_file_documents.install.documents : {
    data : yamldecode(v)
    content : v
    }
  ]
  sync = [for v in data.kubectl_file_documents.sync.documents : {
    data : yamldecode(v)
    content : v
    }
  ]
}
# ===============================================================