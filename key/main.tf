resource "tls_private_key" "cluster_bootstrap_keypair" {
  algorithm = "RSA"
  rsa_bits = var.cluster_keypair_length
}