variable "provider-profile" {
  type = string
  description = "AWS profile set up for AWS CLI"
}

variable "aws_key_name" {
  type = string
  description = "Name of the AWS keypair"
}

variable "private_key_path" {
  type = string
  description = "Absolute path to private key of AWS keypair saved in your local machine"
}

variable "region" {
  type = string
  description = "AWS region in which you want to provision the cluster"
}


variable "k8s_pod_cidr" {
  type = string
  description = "CIDR for Kubernetes pod network"
}

variable "ec2user" {
  type = string
  description = "User in EC2 instance used for managing the cluster"
}

variable "worker_count" {
  type = number
  description = "Number of worker you wish to have in the cluster"
}

variable "your_ip_address" {
  type = string
  description = "Your local IP given by your ISP, this is to allow SSH connection to EC2 instances provisioned"
}

variable "aws_vpc_cidr" {
  type = string
  description = "CIDR of AWS VPC"
}

variable "aws_subnet_cidr" {
  type = string
  description = "CIDR of subnet in which you want EC2 instances to reside, MUST be subset of value in aws_vpc_cidr"
}

variable "cluster_keypair_length" {
  type = number
  description = "Length of the keypair used to establish passwordless SSH for master node to connect to worker and run k8s cluster join command"
}

variable "instance_type" {
  type = string
  default = "t2.medium"
  description = "AWS EC2 instance type, MUST be at least t2.medium due to Kubernetes requirement"
}

