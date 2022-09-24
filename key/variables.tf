variable "cluster_keypair_length" {
  type = number
  description = "Length of the keypair used to establish passwordless SSH for master node to connect to worker and run k8s cluster join command"
  default = 4096
}
