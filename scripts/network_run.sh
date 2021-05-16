#!/usr/bin/env bash

if [[ $# -eq 0 ]] ; then
    echo 'Network folder name is missing'
    exit 0
fi

FOLDER_NAME="$1"

# Go to hyperledgerFabric folder
cd `dirname $0`/../hyperledgerFabric

./init.sh ./$FOLDER_NAME/ ./chaincode/

helm install hlf-kube ./hlf-kube/ -f $FOLDER_NAME/network.yaml -f $FOLDER_NAME/crypto-config.yaml --set peer.launchPods=false --set orderer.launchPods=false 

./collect_host_aliases.sh ./$FOLDER_NAME/

helm upgrade hlf-kube ./hlf-kube/ -f $FOLDER_NAME/network.yaml -f $FOLDER_NAME/crypto-config.yaml -f $FOLDER_NAME/hostAliases.yaml 

echo "Wait until orderer pods are all running..."
while [[ $(kubectl get pods -l name=hlf-orderer -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') == *"False"* ]]; do echo "waiting for orderer pods" && sleep 1; done

echo "Wait until peer pods are all running..."
while [[ $(kubectl get pods -l name=hlf-peer -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') == *"False"* ]]; do echo "waiting for peer pods" && sleep 1; done

# we don't check for CA because if peers and orderers are running then CA pods are also running. 

echo "Run channel flow..."
helm template channel-flow/ -f $FOLDER_NAME/network.yaml -f $FOLDER_NAME/crypto-config.yaml -f $FOLDER_NAME/hostAliases.yaml | argo submit - --watch


sleep 5 

echo "Run chaincode flow..."
helm template chaincode-flow/ -f $FOLDER_NAME/network.yaml -f $FOLDER_NAME/crypto-config.yaml  -f $FOLDER_NAME/hostAliases.yaml | argo submit - --watch
