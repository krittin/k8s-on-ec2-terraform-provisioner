${userdata_logging}
yum install -y containerd
sed -ie 's/disabled_plugins = \[.*\]/disabled_plugins = []/g' /etc/containerd/config.toml 
systemctl enable --now containerd
