#!/usr/bin/env bash

# change time zone
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
timedatectl set-timezone Asia/Shanghai

rm /etc/yum.repos.d/CentOS-Base.repo
cp /vagrant/yum/*.* /etc/yum.repos.d/
mv /etc/yum.repos.d/CentOS7-Base-aliyun.repo /etc/yum.repos.d/CentOS-Base.repo

yum install -y wget curl conntrack-tools vim net-tools telnet tcpdump bind-utils socat ntp kmod

# enable ntp to sync time
echo 'sync time'
systemctl start ntpd
systemctl enable ntpd

# 关闭selinux
echo 'disable selinux'
setenforce 0
sed -i '/SELINUX=/s/enforcing/disabled/' /etc/selinux/config

# 开启iptable转发
echo 'enable iptable kernel parameter'
cat >> /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables=1
net.bridge.bridge-nf-call-iptables=1
net.ipv4.ip_forward=1
EOF
modprobe br_netfilter
sysctl -p /etc/sysctl.d/kubernetes.conf

# 域名解析
echo 'set host name resolution'
cat >> /etc/hosts <<EOF
192.168.205.10 node-master
192.168.205.11 node-worker-1
EOF
cat /etc/hosts

# 关闭防火墙
echo 'disable firewall'
systemctl stop firewalld
systemctl disable firewalld

# 关闭swap分区
echo 'disable swap'
swapoff -a
sed -i '/swap/s/\(.*\)/#&/g' /etc/fstab

# create group if not exists
egrep "^docker" /etc/group >& /dev/null
if [ $? -ne 0 ]
then
  groupadd docker
fi

usermod -aG docker vagrant

# 安装docker-ce
curl https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo -o /etc/yum.repos.d/docker-ce.repo
yum makecache fast
yum -y install docker-ce-18.09.1
systemctl enable docker
systemctl start docker

mkdir -p /etc/systemd/system/docker.service.d
touch /etc/systemd/system/docker.service.d/http-proxy.conf

# 修改cgroupdriver
cat >> /etc/docker/daemon.json <<EOF
{
    "registry-mirrors": ["https://no7knd7p.mirror.aliyuncs.com"],
    "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
systemctl daemon-reload
systemctl restart docker

# 配置阿里云kubernetes源
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

# 安装kubeadm
yum -y install kubelet kubeadm kubectl   # 安装指定版本kubelet-1.14.2-0
systemctl enable kubelet

