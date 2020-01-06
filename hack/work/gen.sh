#!/bin/bash

# 创建私钥
openssl genrsa -out backend.key 2048

ls
cat backend.key

# 使用私钥生成证书请求
openssl req -new -key backend.key -out backend.csr -subj "/CN=backend/0=dev"

ls
cat backend.csr

# 使用CA进行签名。K8S默认的证书目录为 /etc/kubernetes/pki
openssl x509 -req -in backend.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out backend.crt -days 365

ls

# 查看生成的证书文件
openssl x509 -in backend.crt -text -noout
