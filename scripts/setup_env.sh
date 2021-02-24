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
if [[ -f terraform/cloud.yaml ]]
then
    echo "export OS_CLOUD=mycloud"
    export OS_CLOUD=terraform/cloud.yaml
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
    source venv/bin/activate
    # python3 -m pip install -r requirements.txt
    # python3 -m pip install -r kubespray/requirements.txt
    set +x
fi

# Create ansible.log file if not present
if [[ ! -f ansible.log ]]
then
    touch ansible.log
fi
