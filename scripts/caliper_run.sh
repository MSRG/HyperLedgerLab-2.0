#!/usr/bin/env bash
set -x

if [ $# -ne 1 ] ; then
    echo "usage: caliper_run.sh <chaincode_name>" 
    exit 2
fi

CHAINCODE_NAME="$1"

# delete existing caliper 
kubectl delete jobs caliper-manager
kubectl delete jobs caliper-worker
kubectl delete configmap  benchmarks
kubectl delete configmap network
kubectl delete configmap workload
kubectl delete configmap caliper-config  
kubectl delete configmap caliper-report-git

kubectl delete deployment mosquitto
kubectl delete svc mosquitto

# Go to hyperledgerCaliper folder
cd `dirname $0`/../hyperledgerCaliper

if [ ! -d  $CHAINCODE_NAME ] ; then
    echo "ERROR: Invalid chaincode folder name"
    exit 0
fi

helm template config-template/ -f ./$CHAINCODE_NAME/benchmarks/config.yaml -f ../hyperledgerFabric/network-configuation.yaml --output-dir .

kubectl apply -f mosquitto/

kubectl create configmap benchmarks --from-file=./$CHAINCODE_NAME/benchmarks/

kubectl create configmap workload --from-file=./$CHAINCODE_NAME/workload/

kubectl create configmap network --from-file=./caliper-config/templates/networkConfig.yaml

kubectl create configmap caliper-config --from-file=./caliper-config/templates/caliper.yaml

kubectl create configmap caliper-report-git --from-file=./git.yaml

kubectl apply -f caliper-config/templates/caliper-deployment.yaml 

kubectl apply -f caliper-config/templates/caliper-deployment-worker.yaml 

set +x
