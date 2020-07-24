variable "cluster_name" {
  type        = string
  description = "Name of the parent cluster"
}

variable "sub_cluster_name" {
  type        = string
  description = "Name to use for the module sub-cluster"
  default     = "nginx"
}

variable "admin_username" {
  type        = string
  description = "Admin user"
  default     = "nginx_admin"
}

variable "admin_email" {
  type        = string
  description = "Admin user's email address"
  default     = "devops@ctic-inc.com"
}

variable "resource_group" {
  description = "Resource group to provision within"
}

variable "parent_vnetwork_name" {
  type = string
  description = "Name of the virtual network this subnet will live under"
}

variable "environment" {
  type        = string
  description = "Current Environment to provision within"
}

variable "default_tags" {
  type        = map(string)
  description = "Collection of default tags to apply to all resources"
}

variable "mqtt_ip_address" {
  type = string
  description = "IP address of the MQTT broker node"
}

variable "consul_server" {
  type        = string
  description = "IP address of a Consul server to join" 
}
