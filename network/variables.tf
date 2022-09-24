variable "your_ip_address" {
  type = string
  description = "Your local IP given by your ISP, this is to allow SSH connection to EC2 instances provisioned"
}

variable "aws_vpc_cidr" {
  type = string
  description = "CIDR of AWS VPC"
  default = "10.0.0.0/16"
}

variable "aws_subnet_cidr" {
  type = string
  description = "CIDR for the subnet in which EC2 will be launched, MUST BE subset of aws_vpc_cidr"
  default = "10.0.0.0/24"
}