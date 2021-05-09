#!/usr/bin/env bash
set -x

if [[ $# -eq 0 ]] ; then
    echo 'chaincode name is missing'
    exit 0
fi

# Go to benchmarking folder
cd `dirname $0`/../benchmarking

kubectl apply -f mosquitto/

kubectl create configmap benchmarks --from-file=./$1/benchmarks/

kubectl create configmap workload --from-file=./$1/workload/

kubectl create configmap network --from-file=./networks/

kubectl create configmap caliper-config --from-file=./caliper.yaml

kubectl apply -f caliper-deployment.yaml 

kubectl apply -f caliper-deployment-worker.yaml 

kubectl get pods --output=wide -w

set +x
