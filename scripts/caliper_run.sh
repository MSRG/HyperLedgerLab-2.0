#!/usr/bin/env bash

if [ $# -ne 1 ] ; then
    echo "usage: caliper_run.sh <chaincode_name>" 
    exit 2
fi

CHAINCODE_NAME="$1"

# Move to caliper folder
cd `dirname $0`/../caliper

if [ ! -d  ./benchmarks/$CHAINCODE_NAME ] ; then
    echo "ERROR: Invalid chaincode folder name"
    exit 0
fi

set -x

helm template config-template/ -f ./benchmarks/$CHAINCODE_NAME/config.yaml -f ../fabric/network-configuration.yaml --output-dir .

kubectl apply -f mosquitto/

kubectl create configmap benchmarks --from-file=./benchmarks/$CHAINCODE_NAME/config.yaml

kubectl create configmap workload --from-file=./benchmarks/$CHAINCODE_NAME

kubectl create configmap network --from-file=./caliper-config/templates/networkConfig.yaml

kubectl create configmap caliper-config --from-file=./caliper-config/templates/caliper.yaml

kubectl create secret caliper-report-git --from-file=./git.yaml

kubectl apply -f caliper-config/templates/caliper-deployment.yaml 

kubectl apply -f caliper-config/templates/caliper-deployment-worker.yaml 

set +x

echo "Wait until caliper manager pod is running..."
while [[  $(kubectl get pods -l app=caliper-manager -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') == *"False"* ]] || [[ -z $(kubectl get  pods -l app=caliper-manager) ]] ; do echo "waiting for the caliper manager pod to run..." && sleep 5; done
kubectl logs -l app=caliper-manager -f

