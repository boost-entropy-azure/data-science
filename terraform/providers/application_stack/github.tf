# ======================= GITHUB =========================
# 
# SSH Deploy Key to use by Flux CD
resource "tls_private_key" "main" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "github_repository_deploy_key" "main" {
  title      = var.cluster_name
  repository = data.github_repository.main.name
  key        = tls_private_key.main.public_key_openssh
  read_only  = true
}

resource "github_repository_file" "install" {
  repository = data.github_repository.main.name
  file       = data.flux_install.main.path
  content    = data.flux_install.main.content
  branch     = var.flux_repo_branch
}

resource "github_repository_file" "sync" {
  repository = data.github_repository.main.name
  file       = data.flux_sync.main.path
  content    = data.flux_sync.main.content
  branch     = var.flux_repo_branch
}

resource "github_repository_file" "kustomize" {
  repository = data.github_repository.main.name
  file       = data.flux_sync.main.kustomize_path
  content    = data.flux_sync.main.kustomize_content
  branch     = var.flux_repo_branch
}
# =========================================================