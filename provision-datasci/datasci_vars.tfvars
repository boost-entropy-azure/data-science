location           = "East US"
environment        = "dev"
cluster_name       = "datasci"
node_count         = 3
admin_username     = "datasci_admin"
azure_cloud_name   = "AzureCloud"
azure_cloud_domain = "windows.net"

ansible_pwfile     = "~/.vaultpw"

default_tags = {
  Department  = "Monkey"
  PoC         = "DINO"
  Environment = "DEV"
}