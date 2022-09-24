variable "userdata_logging" {
  type = string
  default = <<EOF
#!/bin/bash -xe
exec > >(tee -a /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
EOF
}

variable "instance_type" {
  type = string
  default = "t2.medium"
}

variable aws_key_name {}
variable aws_privatekey_path {}
variable aws_subnet_id {}
variable aws_vpc_security_group_ids {}

variable ec2user {}

variable common_package_installer_script {}
variable docker_installer_script {}
variable k8s_installer_script {}

variable k8s_pod_cidr {}
variable worker_ip_list {}
variable k8s_cluster_bootstrap_privatekey {}
