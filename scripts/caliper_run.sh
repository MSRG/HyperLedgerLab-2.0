#!/usr/bin/env bash
set -x

if [ $# -ne 2 ] ; then
    echo "Illegal number of parameters"
    exit 0
fi

CHAINCODE_NAME="$1"
NETWORK_FOLDER_NAME="$2"

if [[ -d $CHAINCODE_NAME ]] ; then
    echo "Invalid chaincode folder name"
    exit 0
fi

if [[ -d networks/$NETWORK_FOLDER_NAME ]] ; then
    echo "Invalid networkConfig folder name"
    exit 0
fi

# Go to hyperledgerCaliper folder
cd `dirname $0`/../hyperledgerCaliper

kubectl apply -f mosquitto/

kubectl create configmap benchmarks --from-file=./$CHAINCODE_NAME/benchmarks/

kubectl create configmap workload --from-file=./$CHAINCODE_NAME/workload/

kubectl create configmap network --from-file=./networks/$NETWORK_FOLDER_NAME

kubectl create configmap caliper-config --from-file=./caliper.yaml

kubectl apply -f caliper-deployment.yaml 

kubectl apply -f caliper-deployment-worker.yaml 

kubectl get pods --output=wide -w

set +x
