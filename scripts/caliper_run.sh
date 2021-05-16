#!/usr/bin/env bash
set -x

if [[ $# -l 3 ]] ; then
    echo '2 arguments are expected'
    exit 0
fi

CHAINCODE_NAME="$1"
NETWORK_FOLDER_NAME="$2"

# Go to benchmarking folder
cd `dirname $0`/../benchmarking

kubectl apply -f mosquitto/

kubectl create configmap benchmarks --from-file=./$CHAINCODE_NAME/benchmarks/

kubectl create configmap workload --from-file=./$CHAINCODE_NAME/workload/

kubectl create configmap network --from-file=./networks/$NETWORK_FOLDER_NAME

kubectl create configmap caliper-config --from-file=./caliper.yaml

kubectl apply -f caliper-deployment.yaml 

kubectl apply -f caliper-deployment-worker.yaml 

kubectl get pods --output=wide -w

set +x
