data "template_cloudinit_config" "worker-provisioner" {
  gzip = false
  base64_encode = false
  count = var.worker_count
  part {
    content_type = "text/x-shellscript"
    content = <<EOF
${var.userdata_logging}
sudo hostnamectl set-hostname 'k8s-worker${count.index+1}'
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
}

resource "aws_instance" "worker" {

  ami = "ami-0fc841be1f929d7d1" #RedHat8
  instance_type = var.instance_type
  count = var.worker_count
  key_name = var.aws_key_name

  subnet_id = var.aws_subnet_id
  vpc_security_group_ids = var.aws_vpc_security_group_ids

  user_data = data.template_cloudinit_config.worker-provisioner.*.rendered[count.index]

  tags = {
    Name = "k8s-worker${count.index+1}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo '${var.k8s_cluster_bootstrap_publickey}' >> /home/${var.ec2user}/.ssh/authorized_keys"
    ]

    connection {
      type = "ssh"
      host = self.public_ip
      user = var.ec2user
      private_key = file(var.aws_privatekey_path)
    }
    
  }

}