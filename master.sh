#!/usr/bin/env bash

echo 'This is master'

bash /vagrant/kubeadm_images_pull.sh
docker images

# ip of this box
IP_ADDR=`ifconfig eth1 | grep mask | awk '{print $2}'| cut -f2 -d:`
echo $IP_ADDR

# install k8s master
HOST_NAME=$(hostname -s)
kubeadm init --apiserver-advertise-address=$IP_ADDR --apiserver-cert-extra-sans=$IP_ADDR --node-name $HOST_NAME --pod-network-cidr 172.33.0.0/16
# 使master节点可以被调度
kubectl taint nodes --all node-role.kubernetes.io/master:NoSchedule-

# copying credentials to regular user - vagrant
sudo --user=vagrant mkdir -p /home/vagrant/.kube
cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown $(id -u vagrant):$(id -g vagrant) /home/vagrant/.kube/config

# install Calico pod network addon
export KUBECONFIG=/etc/kubernetes/admin.conf
curl https://docs.projectcalico.org/v3.10/manifests/calico.yaml -O
POD_CIDR="172.33.0.0/16" \
sed -i -e "s?192.168.0.0/16?$POD_CIDR?g" calico.yaml

kubectl apply -f calico.yaml

kubeadm token create --print-join-command >> /etc/kubeadm_join_cmd.sh
sed -i -e "s?10.0.2.15?$IP_ADDR?g" /etc/kubeadm_join_cmd.sh
chmod +x /etc/kubeadm_join_cmd.sh

# required for setting up password less ssh between guest VMs
sed -i "/^[^#]*PasswordAuthentication[[:space:]]no/c\PasswordAuthentication yes" /etc/ssh/sshd_config
systemctl restart sshd

