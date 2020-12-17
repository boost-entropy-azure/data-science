location           = "East US"
environment        = "dev"
cluster_name       = "datasci"
node_count         = 3
admin_username     = "datasci_admin"

ansible_pwfile     = "~/.vaultpw"

default_tags = {
  Department  = "Monkey"
  PoC         = "LiveStream"
  Environment = "DEV"
}
