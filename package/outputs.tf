output "k8s" {
  value = data.template_file.k8s-installer.rendered
}

output "containerd" {
  value = data.template_file.containerd-installer.rendered
}

output "common-package" {
  value = data.template_file.common-package-installer.rendered
}

