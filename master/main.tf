data "template_file" "cluster-bootstrap" {
  template = "${file("${path.module}/scripts/cluster-bootstrap.tpl")}"
  vars = {
    k8s_pod_cidr = var.k8s_pod_cidr
    ec2user = var.ec2user
    userdata_logging = var.userdata_logging
    worker_ips = "${join(" ",var.worker_ip_list)}"
    k8s_cluster_bootstrap_privatekey_path = "/home/${var.ec2user}/rsa_pem"
  }
}

data "template_cloudinit_config" "master-provisioner" {
  gzip = false
  base64_encode = false
  count = 1
  part {
    content_type = "text/x-shellscript"
    content = <<EOF
${var.userdata_logging}
sudo hostnamectl set-hostname 'k8s-master${count.index+1}'
EOF
  }

  part {
    content_type = "text/x-shellscript"
    content = var.docker_installer_script
  }
  part {
    content_type = "text/x-shellscript"
    content = var.k8s_installer_script
  }
  part {
    content_type = "text/x-shellscript"
    content = data.template_file.cluster-bootstrap.rendered

  }
}

resource "aws_instance" "master" {

  ami = "ami-0fc841be1f929d7d1" #RedHat8
  instance_type = var.instance_type
  count = 1
  key_name = var.aws_key_name

  subnet_id = var.aws_subnet_id
  vpc_security_group_ids = var.aws_vpc_security_group_ids

  user_data = data.template_cloudinit_config.master-provisioner.*.rendered[count.index]

  tags = {
    Name = "k8s-master${count.index+1}"
  }

  provisioner "file" {
    content = var.k8s_cluster_bootstrap_privatekey
    destination = "/home/${var.ec2user}/rsa_pem"

    connection {
      type = "ssh"
      host = self.public_ip
      user = var.ec2user
      private_key = file(var.aws_privatekey_path)
     }

  }
}
