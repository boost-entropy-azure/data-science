location       = "usgovarizona"
environment    = "dev"
cluster_name   = "datasci"
node_count     = 1
admin_username = "datasci_admin"
mqtt_topics    = ["topic1", "topic2"]
mqtt_password  = "replace_this_password"
mqtt_users     = ["test1", "test2s"]

default_tags   = {
  Department  = "Monkey"
  PoC         = "LiveStream"
  Environment = "DEV"
}
