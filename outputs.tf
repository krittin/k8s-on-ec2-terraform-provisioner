output "masternode_publicip" {
  value = module.master.public_ip
}
output "masternode_publicdns" {
  value = module.master.public_dns
}

output "workermode_publicip" {
  value = module.worker.public_ip_list
}
output "workernode_publicdns" {
  value = module.worker.public_dns_list
}
