output "aws_subnet_id" {
  value = aws_subnet.k8s-subnet.id
}

output "aws_security_group_id_list" {
  value = [
    aws_security_group.management-sg.id,
    aws_security_group.k8s-sg.id,
    aws_security_group.k8s-internode-sg.id
  ]
}