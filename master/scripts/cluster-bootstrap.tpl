${userdata_logging}
# Start Cluster
kubeadm init --config /home/${ec2user}/cluster-config.yml
mkdir -p /home/${ec2user}/.kube
cp -i /etc/kubernetes/admin.conf /home/${ec2user}/.kube/config
chown $(id -u ${ec2user}):$(id -g ${ec2user}) /home/${ec2user}/.kube/config

# Install network addon
sudo -u ${ec2user} kubectl apply -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml

cat <<E > /home/${ec2user}/join-cluster-config.yml
apiVersion: kubeadm.k8s.io/v1beta2
kind: JoinConfiguration
discovery:
  bootstrapToken:
    apiServerEndpoint: 10.0.0.205:6443
    caCertHashes:
    - sha256:1cae568bb631a5441843217c8162016158be4f214ef5e79f0f169171f6e799b7
    token: bbp7q4.qin1uz585i5a15cl
nodeRegistration:
  kubeletExtraArgs:
    cloud-provider: aws
E

count=0
while ! [ $count -lt 10 ] ;do
  if [ -e ${k8s_cluster_bootstrap_privatekey_path} ] ;then
  	break
  else
    sleep 5
    ((count=count+1))
  fi
done

chmod 600 ${k8s_cluster_bootstrap_privatekey_path}
kubeadm token create --print-join-command > /home/${ec2user}/join_cluster.sh
chmod a+x /home/${ec2user}/join_cluster.sh
for worker in ${worker_ips}
do
  count=0
  while [ $count -lt 5  ] ; do
  	ssh-keyscan $worker >> /root/.ssh/known_hosts
    rsync -a -e "ssh -i ${k8s_cluster_bootstrap_privatekey_path}" /home/${ec2user}/join_cluster.sh ${ec2user}@$worker:/home/${ec2user}
    ssh -i ${k8s_cluster_bootstrap_privatekey_path} ${ec2user}@$worker 'sudo /home/${ec2user}/join_cluster.sh; rm /home/${ec2user}/join_cluster.sh'
    rc=$?
    echo "rc=$rc"
    if [ $rc -gt 0 ] ;then
      echo "Waiting 5s"
      sleep 5
      ((count=count+1))
    else
      break
    fi
  done
done

rm ${k8s_cluster_bootstrap_privatekey_path}