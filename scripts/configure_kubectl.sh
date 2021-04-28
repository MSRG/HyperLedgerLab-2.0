#!/usr/bin/env bash

set -x

if [[ $# -eq 0 ]] ; then
    echo 'argument is missing'
    exit 0
fi

mkdir ~/.kube/
ssh ubuntu@$1 sudo cat /etc/kubernetes/kubelet.conf > ~/.kube/config
ssh ubuntu@$1 sudo cat /etc/kubernetes/ssl/apiserver-kubelet-client.key > admin.key
ssh ubuntu@$1 sudo cat /etc/kubernetes/ssl/apiserver-kubelet-client.crt > admin.crt
ssh ubuntu@$1 sudo cat /etc/kubernetes/ssl/ca.crt > ca.crt
kubectl config set-cluster default-cluster --server=https://$1:6443 --certificate-authority=ca.crt
kubectl config set-credentials default-admin --certificate-authority=ca.crt --client-key=admin.key --client-certificate=admin.crt
kubectl config set-context default-system --cluster=default-cluster --user=default-admin
kubectl config use-context default-system
kubectl version

set +x