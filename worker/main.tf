data "template_cloudinit_config" "worker-provisioner" {
  gzip = false
  base64_encode = false
  count = var.worker_count
  part {
    content_type = "text/x-shellscript"
    content = <<EOF
${var.userdata_logging}
sudo hostnamectl set-hostname $(curl http://169.254.169.254/latest/meta-data/local-hostname)
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

resource "aws_iam_instance_profile" "worker-profile" {
  name = "worker-profile"
  role = "worker-role"
}

resource "aws_instance" "worker" {

  ami = "ami-0fc841be1f929d7d1" #RedHat8
  instance_type = var.instance_type
  count = var.worker_count
  key_name = var.aws_key_name

  iam_instance_profile = aws_iam_instance_profile.worker-profile.name

  subnet_id = var.aws_subnet_id
  vpc_security_group_ids = var.aws_vpc_security_group_ids

  user_data = data.template_cloudinit_config.worker-provisioner.*.rendered[count.index]

  tags = {
    Name = "k8s-worker${count.index+1}"
    KubernetesCluster = "owned"
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