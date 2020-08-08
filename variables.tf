variable "provider-profile" {
  type = string
}

variable "private_key_path" {
  type = string
}

variable "region" {
  type = string
}

variable "aws_key_name" {
  type = string
}

variable "k8s_pod_cidr" {
  type = string
  description = "CIDR for Pod Network"
}

variable "ec2user" {
  type = string
}

variable "ami" {
  type = string
  description = "ID of AMI to be used"
  default = "ami-0fc841be1f929d7d1" #RedHat 8
}

variable "worker_count" {
  type = number
}

variable "userdata_logging" {
  type = string
  default = <<EOF
#!/bin/bash -xe
exec > >(tee -a /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
EOF
}

variable "k8s_cluster_bootstrap_privatekey_path" {
  type = string
  default = "/home/ec2-user/rsa_pem"
}

variable "your_ip_address" {
  type = string
  description = "Your local IP given by your ISP, this is to allow SSH connection to EC2 instances provisioned"
}

variable "aws_vpc_cidr" {
  type = string
}

variable "aws_subnet_cidr" {
  type = string
}

variable "cluster_keypair_length" {
  type = number
  description = "Length of the keypair used to establish passwordless SSH for master node to connect to worker and run k8s cluster join command"
}

variable "instance_type" {
  type = string
  default = "t2.medium"
}

