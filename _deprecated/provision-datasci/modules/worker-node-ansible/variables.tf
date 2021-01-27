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

variable "user" {
  default = ""
  description = "User name for the datasci node"
}

variable "playbook" {
  default = ""
  description = "Playbook to run"
}