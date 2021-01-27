# Create an Azure File Share for Prometheus config
resource "azurerm_storage_share" "prometheus_config" {
  name                 = join("-", [var.cluster_name, var.environment, "prometheus-config-file-share"])
  storage_account_name = var.storage_account_name
  quota                = 1
}

# Create the Prometheus Container group
resource "azurerm_container_group" "datasci_monitor" {
  name                = join("-", [var.cluster_name, var.environment, "monitor"])
  resource_group_name = var.resource_group_name
  location            = var.location
  ip_address_type     = "private"
  network_profile_id = var.network_profile_id
  os_type             = "Linux"

  tags = var.default_tags

  # Prometheus Server
  container {
    name   = "prometheus"
    image  = "prom/prometheus"
    cpu    = "1.0"
    memory = "3.0"

    ports {
      port     = 9090
      protocol = "TCP"
    }

    volume {
      name       = "prometheus-conf"
      mount_path = "/etc/prometheus"
      read_only  = "false"
      share_name = azurerm_storage_share.prometheus_config.name

      storage_account_name = var.storage_account_name
      storage_account_key  = var.storage_account_key
    }
  }

  container {
    name   = "consul-exporter"
    image  = "prom/consul-exporter"
    cpu    = "1.0"
    memory = "1.0"
    commands = ["/bin/consul_exporter","--consul.server=${var.consul_server_ip}:8500"]

    ports {
      port     = 9107
      protocol = "TCP"
    }
  }
}

resource "random_id" "default" {
  byte_length = 8
}

data "archive_file" "default" {
  type        = "zip"
  source_dir  = path.module
  output_path = "${path.module}/${random_id.default.hex}.zip"
}

resource "null_resource" "monitor-provisioner" {
  depends_on = [data.archive_file.default]

  provisioner "local-exec" {
    command = "ansible-galaxy install cloudalchemy.node-exporter"
  }

 triggers = {
    signature = data.archive_file.default.output_md5
    command   = "ansible-playbook -e reverse_proxy_ip=${var.reverse_proxy_ip} -e mqtt_server_ip=${var.mqtt_server_ip} -e worker_node_ips=${var.worker_node_ips} -e account_name=${var.storage_account_name} -e account_key=${var.storage_account_key} -e share_name=${azurerm_storage_share.prometheus_config.name} ${path.module}/monitor_play.yml"
  }

  provisioner "local-exec" {
    command   = "ansible-playbook -e reverse_proxy_ip=${var.reverse_proxy_ip} -e mqtt_server_ip=${var.mqtt_server_ip} -e worker_node_ips=${var.worker_node_ips} -e account_name=${var.storage_account_name} -e account_key=${var.storage_account_key} -e share_name=${azurerm_storage_share.prometheus_config.name} ${path.module}/monitor_play.yml"
  }
}
