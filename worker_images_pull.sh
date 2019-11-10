#!/bin/bash

VERSION=`kubelet --version | awk -F'v' '{print $2}'`
gcr_repo="k8s.gcr.io"
mirror_repo="gcr.azk8s.cn/google_containers"

for i in $(kubeadm config images list --kubernetes-version ${VERSION} | awk -F'/' '{print $2}' | egrep "proxy|pause")
do
  docker pull ${mirror_repo}/$i
  docker tag ${mirror_repo}/$i ${gcr_repo}/$i
  docker rmi ${mirror_repo}/$i
done
