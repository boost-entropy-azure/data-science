location       = "usgovarizona"
environment    = "dev"
cluster_name   = "fetest"
node_count     = 3
admin_username = "datasci_admin"

ansible_pwfile = "~/.vaultpw"

default_tags   = {
  Department  = "Monkey"
  PoC         = "LiveStream"
  Environment = "DEV"
}

mqtt_topics = ["lte_message","umts_message","cdma_message","gsm_message","80211_beacon_message","energy_detection_message","signal_detection_message"]
//mqtt_topics = ["lte_message"]
mqtt_users  = ["dino", "christian", "les", "steve", "shared"]


