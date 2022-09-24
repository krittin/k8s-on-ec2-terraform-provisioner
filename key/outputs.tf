output "cluster_bootstrap_privatekey" {
  value = tls_private_key.cluster_bootstrap_keypair.private_key_pem
  sensitive = true
}
output "cluster_bootstrap_publickey" {
  value = tls_private_key.cluster_bootstrap_keypair.public_key_openssh
  sensitive = true
}