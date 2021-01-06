#### Dependencies ####
# - None

data "http" "myip" {
  url = "http://ipecho.net/plain"
}
