
# Kubernetes Cluster Provisioner for AWS EC2 
This Terraform configuration is for provisioning Kubernetes cluster on AWS EC2 nodes.
The end-result when this configuration is run is you will get a single control-plane Kubernetes cluster running on a configurable number of EC2 worker nodes.

## Prerequisites
Following are required for this configuration to run successfully
- Terraform installed on your local machine - this configuration has been tested on Terraform v0.12.26
- AWS 
  - You have AWS account setup
  - [AWS CLI version 2](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) is installed on your local machine
  - AWS profile is set up for your AWS CLI
  - You have created [AWS EC2 keypair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) and saved the private key (.pem) on your local machine

## Warning on AWS cost
You will incur some cost when running this configuration. This is due to the requirement of [Kubernetes cluster](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/) which is nodes have to have:
> 2 GB or more of RAM per machine (any less will leave little room for your apps)<br>
> 2 CPUs or more

Therefore, the instance type of EC2 nodes spun up by this configuration must be at at least t2.medium.
Please check costs associated each instance type [here](https://aws.amazon.com/ec2/instance-types/t2/)


## This configuration is opinionated
This configuration is opinionated. It 
- is a single control-plane Kubernetes cluster so there will be only 1 master node
- uses RedHat8 AMI 
- logs userdata of EC2 nodes to /var/log/user-data.log
- uses Calico network add-on for Kubernetes cluster

## How to run
```
    git clone https://github.com/krittin/k8s-on-ec2-terraform-provisioner.git
    cd k8s-on-ec2-terraform-provisioner
    terraform init
    terraform apply
```
