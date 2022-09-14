# ======================= GITHUB =========================
# 
# SSH Deploy Key to use by Flux CD
provider "gitlab" {
  token            = var.gitlab_token
  base_url         = var.flux_repo_url
  early_auth_check = true
}
# =========================================================