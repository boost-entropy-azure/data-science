resource "null_resource" "provisioner" {
  provisioner "local-exec" {
    command = "ansible-playbook -e ${join(" -e ", compact(var.arguments))} ${path.module}/mqtt_play.yml"
  }
}
