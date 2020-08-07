output "docker" {
  value = data.template_file.docker-installer.rendered
}

output "k8s" {
  value = data.template_file.k8s-installer.rendered
}