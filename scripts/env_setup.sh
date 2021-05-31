#!/usr/bin/env bash

set -e

TERRAFORM_VERSION=0.15.0
KUBECTL_VERSION=v1.21.0
HELM_VERSION=v3.0.0
JQ_VERSION=1.5+dfsg-2
ARGO_VERSION=v3.0.0-rc5

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

# Setup python environment
set -x
sudo apt update
sudo apt-get install --yes python3-pip
sudo pip3 install -r kubespray/requirements.txt
set +x

# #Install Ansible
# if dpkg --get-selections | grep -q "^ansible[[:space:]]*install$" >/dev/null; 
#     then
#         echo -e "ansible already installed"
#     else
#         sudo apt install --yes software-properties-common
#         sudo apt-add-repository --yes --update ppa:ansible/ansible
#         sudo apt install --yes ansible
# fi

# Install Terraform
if dpkg --get-selections | grep -q "^terraform[[:space:]]*install$" >/dev/null; 
    then
        echo -e "terraform already installed"
    else
        curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
        sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
        sudo apt-get update && sudo apt-get install --yes terraform=$TERRAFORM_VERSION
fi

# Install Kubectl 
if compgen -c | grep -q "^kubectl" >/dev/null; 
    then
        echo -e "kubectl already installed"
    else
        curl -LO "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl"
        curl -LO "https://dl.k8s.io/$KUBECTL_VERSION/bin/linux/amd64/kubectl.sha256"
        echo "$(<kubectl.sha256) kubectl" | sha256sum --check
        sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
fi

# Install Helm
if compgen -c | grep -q "^helm" >/dev/null; 
    then
        echo -e "helm already installed"
    else
        curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
        chmod 700 get_helm.sh 
        ./get_helm.sh -v $HELM_VERSION
fi

# Install jq
if dpkg --get-selections | grep -q "^jq[[:space:]]*install$" >/dev/null; 
    then
        echo -e "jq already installed"
    else
        sudo apt-get install --yes jq=$JQ_VERSION
fi

# Install argo cli
if compgen -c | grep -q "^argo" >/dev/null; 
    then
        echo -e "argo already installed"
    else
        # Download the binary
        curl -sLO https://github.com/argoproj/argo/releases/download/$ARGO_VERSION/argo-linux-amd64.gz
        # Unzip
        gunzip argo-linux-amd64.gz
        # Make binary executable
        chmod +x argo-linux-amd64
        # Move binary to path
        sudo mv ./argo-linux-amd64 /usr/local/bin/argo
        # Test installation
        argo version
fi

# Create ansible.log file if not present
if [[ ! -f ansible.log ]]
then
    touch ansible.log
fi
