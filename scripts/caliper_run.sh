#!/usr/bin/env bash
set -x

if [ $# -ne 2 ] ; then
    echo "usage: caliper_run.sh <chaincode_name> <network_folder_name>s" 
    exit 2
fi

CHAINCODE_NAME="$1"
NETWORK_FOLDER_NAME="$2"

# Go to hyperledgerCaliper folder
cd `dirname $0`/../hyperledgerCaliper

if [ ! -d  $CHAINCODE_NAME ] ; then
    echo "Invalid chaincode folder name"
    exit 0
fi

if [ ! -d networks/$NETWORK_FOLDER_NAME ] ; then
    echo "Invalid networkConfig folder name"
    exit 0
fi

kubectl apply -f mosquitto/

kubectl create configmap benchmarks --from-file=./$CHAINCODE_NAME/benchmarks/

kubectl create configmap workload --from-file=./$CHAINCODE_NAME/workload/

kubectl create configmap network --from-file=./networks/$NETWORK_FOLDER_NAME

kubectl create configmap caliper-config --from-file=./caliper.yaml

kubectl create configmap caliper-report-git --from-file=./report-git-repository.yaml

kubectl apply -f caliper-deployment.yaml 

kubectl apply -f caliper-deployment-worker.yaml 

set +x
