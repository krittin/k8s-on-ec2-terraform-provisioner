${userdata_logging}

# Start Cluster
kubeadm init --pod-network-cidr ${k8s_pod_cidr}

mkdir -p /home/${ec2user}/.kube
cp -i /etc/kubernetes/admin.conf /home/${ec2user}/.kube/config
chown $(id -u ${ec2user}):$(id -g ${ec2user}) /home/${ec2user}/.kube/config

# Install network addon
yum install -y wget
cd /home/${ec2user}

kubeadm token create --print-join-command > /home/${ec2user}/join_cluster.sh

master_address=
join_token=
join_certhash=

join_cmd=($(cat /home/${ec2user}/join_cluster.sh))

for i in $${!join_cmd[@]} ;do
  case $${join_cmd[$i]} in
    join)
      master_address=$${join_cmd[$i+1]}
    ;;
    --token)
      join_token=$${join_cmd[$i+1]}
    ;;
    --discovery-token-ca-cert-hash)
      join_certhash=$${join_cmd[$i+1]}
    ;;
  esac
done

rm /home/${ec2user}/join_cluster.sh

# Create join cluster config
cat <<E > /home/${ec2user}/join-cluster-config.yml
apiVersion: kubeadm.k8s.io/v1beta2
kind: JoinConfiguration
discovery:
  bootstrapToken:
    apiServerEndpoint: $${master_address}
    caCertHashes:
    - $${join_certhash}
    token: $${join_token}
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
for worker in ${worker_ips}
do
  count=0
  while [ $count -lt 5  ] ; do
  	ssh-keyscan $worker >> /root/.ssh/known_hosts
    rsync -a -e "ssh -i ${k8s_cluster_bootstrap_privatekey_path}" /home/${ec2user}/join-cluster-config.yml ${ec2user}@$worker:/home/${ec2user}
    ssh -i ${k8s_cluster_bootstrap_privatekey_path} ${ec2user}@$worker 'sudo kubeadm join --config /home/${ec2user}/join-cluster-config.yml ; rm /home/${ec2user}/join-cluster-config.yml'
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

kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

sudo -u ${ec2user} echo 'source <(kubectl completion bash)' >> /home/${ec2user}/.bashrc

