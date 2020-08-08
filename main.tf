###########################################################
# Provider
###########################################################
provider "aws" {
  profile = var.provider-profile
  region = var.region
  
}

###########################################################
# Resource
###########################################################

module "key" {
  source = "./key"
  cluster_keypair_length = var.cluster_keypair_length
}


module "network" {
  source = "./network"
  your_ip_address = var.your_ip_address
  aws_vpc_cidr = var.aws_vpc_cidr
  aws_subnet_cidr = var.aws_subnet_cidr
}

module "package" {
  source = "./package"
  ec2user = var.ec2user
}


module "worker" {
  source = "./worker"
  worker_count = 3
  aws_key_name = var.aws_key_name
  instance_type = var.instance_type
  aws_privatekey_path = var.private_key_path
  ec2user = var.ec2user
  docker_installer_script = module.package.docker
  k8s_installer_script = module.package.k8s
  aws_subnet_id = module.network.aws_subnet_id
  aws_vpc_security_group_ids = module.network.aws_security_group_id_list
  k8s_cluster_bootstrap_publickey = module.key.cluster_bootstrap_publickey
}


module "master" {
  source = "./master"
  ec2user = var.ec2user
  instance_type = var.instance_type


  aws_key_name = var.aws_key_name
  aws_privatekey_path = var.private_key_path
  aws_subnet_id = module.network.aws_subnet_id
  aws_vpc_security_group_ids = module.network.aws_security_group_id_list

  docker_installer_script = module.package.docker
  k8s_installer_script = module.package.k8s

  k8s_pod_cidr = var.k8s_pod_cidr
  worker_ip_list = module.worker.ip_list
  k8s_cluster_bootstrap_privatekey = module.key.cluster_bootstrap_privatekey
  
}

