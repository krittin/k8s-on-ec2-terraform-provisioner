output "public_ip" {
	value = aws_instance.master.*.public_ip
}
output "public_dns" {
  value = aws_instance.master.*.public_dns
}