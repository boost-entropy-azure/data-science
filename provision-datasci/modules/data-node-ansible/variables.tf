variable "arguments" {
  default = []
  type    = list(string)
  description = "Arguments"
}

variable "envs" {
  default = []
  type    = list(string)
  description = "Environment variables"
}

variable "inventory" {
  default = ""
  description = "List of group:ip_address:private_ip of hosts in play"
}

variable "user" {
  default = ""
  description = "User name for the datasci node"
}

variable "playbook" {
  default = ""
  description = "Playbook to run"
}