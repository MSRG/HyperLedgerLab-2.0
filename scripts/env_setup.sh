#!/usr/bin/env bash

set -e

DOCKER_CE_VERSION=5:20.10.7~3-0~ubuntu-focal
DOCKER_CE_CLI_VERSION=5:20.10.7~3-0~ubuntu-focal
FABRIC_VERSION=2.2.0
FABRIC_CA_VERSION=1.5.0
YQ_VERSION=v4.2.0
TERRAFORM_VERSION=1.0.0
KUBECTL_VERSION=v1.21.0
HELM_VERSION=v3.0.0
JQ_VERSION=1.6-1ubuntu0.20.04.1
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

# Install docker 
if compgen -c | grep -q "^docker" >/dev/null; 
    then
        echo -e "docker already installed"
    else
        # Install packages to allow apt to use a repository over HTTPS
        sudo apt-get install --yes apt-transport-https ca-certificates curl gnupg lsb-release
        # Add Docker’s official GPG key
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        # set up the stable repository
        echo \
        "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        # Update the apt package index, and install a specific version of Docker Engine and containerd
        sudo apt-get update
        sudo apt-get install --yes docker-ce=$DOCKER_CE_VERSION docker-ce-cli=$DOCKER_CE_CLI_VERSION containerd.io
fi

# Install fabric binaries 
if compgen -c | grep -q "^peer" >/dev/null; 
    then
        echo -e "Fabric binaries already installed"
    else
        # Download the Hyperledger Fabric docker images for the version specified
        curl -sSL https://bit.ly/2ysbOFE | sudo bash -s -- $FABRIC_VERSION $FABRIC_CA_VERSION
        # Move binary to path
        sudo mv -v ./fabric-samples/bin/* /usr/local/bin/
fi

# Install yq
if -f "/usr/local/bin/yq"; 
    then
        echo -e "yq already installed"
    else
        # Download yq
        wget https://github.com/mikefarah/yq/releases/download/$YQ_VERSION/yq_linux_amd64.tar.gz -O - | tar xz
        # Move binary to path
        sudo mv yq_linux_amd64 /usr/local/bin/yq
fi

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
