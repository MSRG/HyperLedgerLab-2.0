#!/usr/bin/env bash

source `dirname $0`/setup_env.sh

set -x
# Setup Openstack instances for k8s nodes using Terraform
cd `dirname $0`/../terraform
terraform destroy -var-file=cluster.tfvars . #Destroy cluster

set +x