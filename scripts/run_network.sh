#!/usr/bin/env bash

if [[ $# -eq 0 ]] ; then
    echo 'Network folder name is missing'
    exit 0
fi


# Go to hyperledgerFabric folder
cd `dirname $0`/../hyperledgerFabric

./init.sh ./$1/ ./chaincode/

helm install hlf-kube ./hlf-kube/ -f $1/network.yaml -f $1/crypto-config.yaml --set orderer.cluster.enabled=true --set peer.launchPods=false --set orderer.launchPods=false 

./collect_host_aliases.sh ./$1/

helm upgrade hlf-kube ./hlf-kube/ -f $1/network.yaml -f $1/crypto-config.yaml -f $1/hostAliases.yaml --set orderer.cluster.enabled=true

echo "Wait until orderer pods are all running..."
while [[ $(kubectl get pods -l name=hlf-orderer -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') == *"False"* ]]; do echo "waiting for orderer pods" && sleep 1; done

echo "Wait until peer pods are all running..."
while [[ $(kubectl get pods -l name=hlf-peer -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') == *"False"* ]]; do echo "waiting for peer pods" && sleep 1; done

# we don't check for CA because if peers and orderers are running then CA pods are also running. 

echo "Run channel flow..."
helm template channel-flow/ -f $1/network.yaml -f $1/crypto-config.yaml -f $1/hostAliases.yaml | argo submit - --watch

sleep 5 

echo "Run chaincode flow..."
helm template chaincode-flow/ -f $1/network.yaml -f $1/crypto-config.yaml  -f $1/hostAliases.yaml | argo submit - --watch
