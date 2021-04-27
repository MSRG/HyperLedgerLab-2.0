#!/usr/bin/env bash

set -e

# override StrictHostKeyChecking in ssh config
touch ~/.ssh/config
cat << EOF > ~/.ssh/config
Host *
    StrictHostKeyChecking accept-new
EOF

chmod 755 ./

# cd to project root
cd `dirname $0`/..

# Update the submodule code
set -x
git submodule sync
git submodule update --init --recursive
set +x

# # Set environment variables required for Openstack and k8s cluster setup
# if [[ -f scripts/cloud.sh ]]
# then
#     echo "export OS_CLOUD=mycloud"
#     source scripts/cloud.sh
#     # export OS_CLOUD=terraform/cloud.yaml
# else
#     echo "Create a cloud.yaml file. Take cloud_sample.yaml as example"
#     exit 1
# fi

# Setup python environment
if [[ -d venv ]]
then
    echo "source venv/bin/activate"
    # source venv/bin/activate
else
    set -x
    mkdir venv
    sudo apt update
    sudo apt-get install --yes python3-pip
    # sudo apt-get install python3-venv
    # python3 -m venv venv
    # source /venv/bin/activate
    # python3 -m pip install -r requirements.txt
    # python3 -m pip install -r kubespray/requirements.txt
    set +x
fi

#Install Ansible
if dpkg --get-selections | grep -q "^ansible[[:space:]]*install$" >/dev/null; 
    then
        echo -e "ansible already installed"
    else
        sudo apt install software-properties-common
        sudo apt-add-repository --yes --update ppa:ansible/ansible
        sudo apt install ansible
fi

# Install Terraform
if dpkg --get-selections | grep -q "^terraform[[:space:]]*install$" >/dev/null; 
    then
        echo -e "terraform already installed"
    else
        curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
        sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
        sudo apt-get update && sudo apt-get install terraform=0.15.0
fi

# Install Kubectl 
if dpkg --get-selections | grep -q "^kubectl[[:space:]]*install$" >/dev/null; 
    then
        echo -e "kubectl already installed"
    else
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
        echo "$(<kubectl.sha256) kubectl" | sha256sum --check
        sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
fi

# Install Helm
if dpkg --get-selections | grep -q "^helm[[:space:]]*install$" >/dev/null; 
    then
        echo -e "helm already installed"
    else
        curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
        chmod 700 get_helm.sh
        ./get_helm.sh
fi

sudo apt-get install jq

# Create ansible.log file if not present
if [[ ! -f ansible.log ]]
then
    touch ansible.log
fi
