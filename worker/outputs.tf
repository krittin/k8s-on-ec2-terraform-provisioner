output "ip_list" {
  value = aws_instance.worker.*.private_ip
}

output "public_ip_list" {
  value = aws_instance.worker.*.public_ip
}

output "public_dns_list" {
  value = aws_instance.worker.*.public_dns
}