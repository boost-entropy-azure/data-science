resource "random_id" "default" {
  byte_length = 8
}

data "archive_file" "default" {
  type        = "zip"
  source_dir  = path.module
  output_path = "${path.module}/${random_id.default.hex}.zip"
}

resource "null_resource" "provisioner" {
  depends_on = [data.archive_file.default]

  triggers = {
    signature = data.archive_file.default.output_md5
    command   = "ansible-playbook ${join(" ", compact(var.arguments))} -e inventory=${join(",", compact(var.inventory))} ${length(compact(var.envs)) > 0 ? "-e" : ""} ${join(" -e ", compact(var.envs))} ${var.playbook}"
  }

  connection {
    user        = var.user
    host        = split(":", var.inventory[0])[1]  # TODO: Wait for all datanodes instead of the first one
    type        = "ssh"
    timeout     = "10m"
  }

  provisioner "remote-exec" {
    script    = "${path.module}/wait_for_instance.sh"
  }

  provisioner "local-exec" {
    command   = "ansible-playbook ${join(" ", compact(var.arguments))} -e inventory=${join(",", compact(var.inventory))} ${length(compact(var.envs)) > 0 ? "-e" : ""} ${join(" -e ", compact(var.envs))} ${var.playbook}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "null_resource" "cleanup" {
  triggers = {
    default = random_id.default.hex
  }

  provisioner "local-exec" {
    command = "rm -f ${data.archive_file.default.output_path}"
  }
}
