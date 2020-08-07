output "ip_list" {
  value = aws_instance.worker.*.private_ip
}