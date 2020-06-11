resource "random_id" "default" {
  byte_length = 8
}

data "archive_file" "default" {
  type        = "zip"
  source_dir  = path.module
  output_path = "${path.module}/${random_id.default.hex}.zip"
}

resource "null_resource" "mqtt-provisioner" {
  depends_on = ["data.archive_file.default"]

  triggers = {
    signature = data.archive_file.default.output_md5
    command   = "ansible-playbook -e ${join(" -e ", compact(var.arguments))} ${path.module}/mqtt_play.yml"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -e ${join(" -e ", compact(var.arguments))} ${path.module}/mqtt_play.yml"
  }
}
