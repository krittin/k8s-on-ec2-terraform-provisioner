${userdata_logging}
# Start Cluster
kubeadm init --pod-network-cidr "${k8s_pod_cidr}" 
mkdir -p /home/${ec2user}/.kube
cp -i /etc/kubernetes/admin.conf /home/${ec2user}/.kube/config
chown $(id -u ${ec2user}):$(id -g ${ec2user}) /home/${ec2user}/.kube/config

# Install network addon
sudo -u ${ec2user} kubectl apply -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml

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