#!/usr/bin/env bash

set -x

if [[ $# -eq 0 ]] ; then
    echo 'Master ip address is missing'
    exit 2
fi

mkdir /home/ubuntu/.kube
mkdir k8s_keys
ssh ubuntu@$1 sudo cat /etc/kubernetes/kubelet.conf > /home/ubuntu/.kube/config
ssh ubuntu@$1 sudo cat /etc/kubernetes/ssl/apiserver-kubelet-client.key > k8s_keys/admin.key
ssh ubuntu@$1 sudo cat /etc/kubernetes/ssl/apiserver-kubelet-client.crt > k8s_keys/admin.crt
ssh ubuntu@$1 sudo cat /etc/kubernetes/ssl/ca.crt > k8s_keys/ca.crt
kubectl config set-cluster default-cluster --server=https://$1:6443 --certificate-authority=k8s_keys/ca.crt
kubectl config set-credentials default-admin --certificate-authority=k8s_keys/ca.crt --client-key=k8s_keys/admin.key --client-certificate=k8s_keys/admin.crt
kubectl config set-context default-system --cluster=default-cluster --user=default-admin
kubectl config use-context default-system
kubectl version

set +x