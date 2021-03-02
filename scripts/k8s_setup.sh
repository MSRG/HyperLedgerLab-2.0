#!/usr/bin/env bash

# source `dirname $0`/setup_env.sh

# ansible-playbook --become -i inventory/infra/hosts.ini playbooks/create_instances.yaml

set -x
# Setup Openstack instances for k8s nodes using Terraform
cd `dirname $0`/../terraform
terraform init . #Install the required plugins
terraform apply -var-file=cluster.tfvars . #Provisioning cluster

echo "Waiting 30 seconds for Openstack instances to boot ....."
sleep 30

#Ensure your local ssh-agent is running and your ssh key has been added. 
#This step is required by the terraform provisioner.
eval $(ssh-agent -s)
ssh-add ~/.ssh/id_rsa 
#Check if all instances are reachable
# ansible -i hosts -m ping all 

# Setup k8s cluster
ansible-playbook --become -i hosts ../kubespray/cluster.yml

# fill hosts.ini with the actual values and configure kubectl
ansible-playbook -i hosts ../playbook.yml

set +x