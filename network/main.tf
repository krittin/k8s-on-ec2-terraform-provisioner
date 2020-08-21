resource "aws_vpc" "k8s-vpc" {
  cidr_block = var.aws_vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    KubernetesCluster = "owned"
  }
  
}

resource "aws_subnet" "k8s-subnet" {
  vpc_id = aws_vpc.k8s-vpc.id
  cidr_block = var.aws_subnet_cidr
  map_public_ip_on_launch = true
  tags = {
    KubernetesCluster = "owned"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.k8s-vpc.id
}

resource "aws_default_route_table" "route-table" {
  default_route_table_id = aws_vpc.k8s-vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    KubernetesCluster = "owned"
  }
}

resource "aws_security_group" "management-sg" {
  name = "management-sg"
  vpc_id = aws_vpc.k8s-vpc.id

  ingress {
    description = "SSH for admin"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "${var.your_ip_address}/32" , aws_subnet.k8s-subnet.cidr_block ]
  }

  egress {
    description = "Allow all"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}

resource "aws_security_group" "k8s-sg" {
  name = "k8s-sg"
  vpc_id = aws_vpc.k8s-vpc.id

  ingress {
    description = "API server port"
    from_port = 6443
    to_port = 6443
    protocol = "tcp"
    cidr_blocks = [ aws_subnet.k8s-subnet.cidr_block ]
  }

  tags = {
    KubernetesCluster = "owned"
  }
  
}

