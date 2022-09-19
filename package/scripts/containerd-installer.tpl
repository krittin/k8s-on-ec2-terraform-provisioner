${userdata_logging}
dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
dnf install -y containerd.io
sed -ie 's/disabled_plugins = \[.*\]/disabled_plugins = []/g' /etc/containerd/config.toml 
systemctl enable --now containerd
