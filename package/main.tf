data "template_file" "k8s-installer" {
  template = "${file("${path.module}/scripts/k8s-installer.tpl")}"
  vars = {
    userdata_logging = <<EOF
#!/bin/bash -xe
exec > >(tee -a /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
EOF
    ec2user = var.ec2user
  }
}

data "template_file" "docker-installer" {
  template = "${file("${path.module}/scripts/docker-installer.tpl")}"
  vars = {
    userdata_logging = <<EOF
#!/bin/bash -xe
exec > >(tee -a /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
EOF 
    ec2user = var.ec2user
  }
}
