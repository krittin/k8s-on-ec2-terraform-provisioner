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
sudo hostnamectl set-hostname $(curl http://169.254.169.254/latest/meta-data/local-hostname)
EOF
  }

  part {
    content_type = "text/x-shellscript"
    content = var.common_package_installer_script
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

resource "aws_iam_policy" "k8s-master-policy" {
  name = "k8s-master-policy"
  policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
        {
            Effect: "Allow",
            Action: [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeTags",
                "ec2:DescribeInstances",
                "ec2:DescribeRegions",
                "ec2:DescribeRouteTables",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeVolumes",
                "ec2:CreateSecurityGroup",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:ModifyInstanceAttribute",
                "ec2:ModifyVolume",
                "ec2:AttachVolume",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:CreateRoute",
                "ec2:DeleteRoute",
                "ec2:DeleteSecurityGroup",
                "ec2:DeleteVolume",
                "ec2:DetachVolume",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:DescribeVpcs",
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:AttachLoadBalancerToSubnets",
                "elasticloadbalancing:ApplySecurityGroupsToLoadBalancer",
                "elasticloadbalancing:CreateLoadBalancer",
                "elasticloadbalancing:CreateLoadBalancerPolicy",
                "elasticloadbalancing:CreateLoadBalancerListeners",
                "elasticloadbalancing:ConfigureHealthCheck",
                "elasticloadbalancing:DeleteLoadBalancer",
                "elasticloadbalancing:DeleteLoadBalancerListeners",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeLoadBalancerAttributes",
                "elasticloadbalancing:DetachLoadBalancerFromSubnets",
                "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
                "elasticloadbalancing:ModifyLoadBalancerAttributes",
                "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
                "elasticloadbalancing:SetLoadBalancerPoliciesForBackendServer",
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:CreateTargetGroup",
                "elasticloadbalancing:DeleteListener",
                "elasticloadbalancing:DeleteTargetGroup",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:DescribeLoadBalancerPolicies",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:ModifyListener",
                "elasticloadbalancing:ModifyTargetGroup",
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:DeregisterTargets",
                "elasticloadbalancing:SetLoadBalancerPoliciesOfListener",
                "iam:CreateServiceLinkedRole",
                "kms:DescribeKey"
            ],
            Resource: [
                "*"
            ]
        }
    ]
  })
}

resource "aws_iam_role" "k8s-master-role" {
  name = "k8s-master-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })  
}

resource "aws_iam_role_policy_attachment" "k8s-master-policy-attached-role" {
  role       = aws_iam_role.k8s-master-role.name
  policy_arn = aws_iam_policy.k8s-master-policy.arn
}

resource "aws_iam_instance_profile" "master-profile" {
  name = "master-profile"
  role = aws_iam_role.k8s-master-role.name
}

data aws_ami "amazon_linux" {
  most_recent = true
  filter {
    name = "name"
    values = ["amzn2-ami*"]
  }
}

resource "aws_instance" "master" {

  ami = data.aws_ami.amazon_linux.id 
  instance_type = var.instance_type
  count = 1
  key_name = var.aws_key_name

  iam_instance_profile = aws_iam_instance_profile.master-profile.name

  subnet_id = var.aws_subnet_id
  vpc_security_group_ids = var.aws_vpc_security_group_ids

  user_data = data.template_cloudinit_config.master-provisioner.*.rendered[count.index]

  tags = {
    Name = "k8s-master${count.index+1}"
    KubernetesCluster = "owned"
  }

  root_block_device {
    volume_size = 20
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

#resource "aws_ebs_volume" "volume" {
#  availability_zone = aws_instance.master[count.index].availability_zone
#  size = 20
#  count = 1
#
#  tags = {
#    Name = "master${count.index+1}-volume"
#  }
#}
#
#resource "aws_volume_attachment" "master_volume_attachment" {
#  count = 1
#  device_name = "/dev/xvdh"
#  volume_id = aws_ebs_volume.volume[count.index].id
#  instance_id = aws_instance.master[count.index].id
#}