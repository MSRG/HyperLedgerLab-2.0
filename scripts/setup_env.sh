#!/usr/bin/env bash

set -e

# cd to project root
cd `dirname $0`/..
echo $PWD

# Update the submodule code
set -x
git submodule sync
git submodule update --init --recursive
set +x

# Set environment variables required for Openstack and k8s cluster setup
if [[ -f scripts/cloud.sh ]]
then
    echo "export OS_CLOUD=mycloud"
    source scripts/cloud.sh
    # export OS_CLOUD=terraform/cloud.yaml
else
    echo "Create a cloud.yaml file. Take cloud_sample.yaml as example"
    exit 1
fi


# Setup python environment
if [[ -d venv ]]
then
    echo "source venv/bin/activate"
    source venv/bin/activate
else
    set -x
    mkdir venv
    sudo apt update
    sudo apt-get install --yes python3-pip
    sudo apt-get install python3-venv
    python3 -m venv venv
    source ./venv/bin/activate
    # python3 -m pip install -r requirements.txt
    # python3 -m pip install -r kubespray/requirements.txt
    set +x
fi

#Install Ansible
sudo apt install software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install ansible

# Install Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform

# Install Kubectl 
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(<kubectl.sha256) kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Create ansible.log file if not present
if [[ ! -f ansible.log ]]
then
    touch ansible.log
fi
