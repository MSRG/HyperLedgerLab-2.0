#!/usr/bin/env bash

source `dirname $0`/env_setup.sh

set -x

# Setup Openstack instances for k8s nodes using Terraform
cd terraform/
terraform init  #Install the required plugins
 #Provisioning cluster
terraform apply -var-file=./cluster.tfvars -auto-approve

echo "Waiting 60 seconds for Openstack instances to boot ....."
sleep 60

#Ensure your local ssh-agent is running and your ssh key has been added. 
#This step is required by the terraform provisioner.
eval $(ssh-agent -s)
ssh-add ~/.ssh/id_rsa 

#Check if all instances are reachable
# ansible -i hosts -m ping all 

# Setup k8s cluster
ansible-playbook --become -i hosts ../kubespray/cluster.yml

# fill hosts.ini with the actual values and configure kubectl
ansible-playbook -i hosts ../terraform/kubectl-config/playbook.yaml

# Install agro controller with the configured kubectl
kubectl create namespace argo
kubectl apply -n argo -f https://raw.githubusercontent.com/argoproj/argo/v3.0.0-rc5/manifests/install.yaml
kubectl create rolebinding default-admin --clusterrole=admin --serviceaccount=default:default

set +x