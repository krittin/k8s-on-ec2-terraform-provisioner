data "template_file" "k8s-installer" {
  template = "${file("${path.module}/scripts/k8s-installer.tpl")}"
  vars = {
    userdata_logging = var.userdata_logging
    ec2user = var.ec2user
  }
}

data "template_file" "docker-installer" {
  template = "${file("${path.module}/scripts/docker-installer.tpl")}"
  vars = {
    userdata_logging = var.userdata_logging
    ec2user = var.ec2user
  }
}
