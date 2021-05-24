#!/usr/bin/env bash

if [[ $# -eq 0 ]] ; then
    echo 'Network folder name is missing'
    exit 0
fi

FOLDER_NAME="$1"

# Go to hyperledgerFabric folder
cd `dirname $0`/../hyperledgerFabric

if [ ! -d  $FOLDER_NAME ] ; then
    echo "Invalid network folder name"
    exit 0
fi

./init.sh ./$FOLDER_NAME/ ./chaincode/

helm install hlf-kube ./hlf-kube/ -f $FOLDER_NAME/network.yaml -f $FOLDER_NAME/crypto-config.yaml --set peer.launchPods=false --set orderer.launchPods=false 

./collect_host_aliases.sh ./$FOLDER_NAME/

helm upgrade hlf-kube ./hlf-kube/ -f $FOLDER_NAME/network.yaml -f $FOLDER_NAME/crypto-config.yaml -f $FOLDER_NAME/hostAliases.yaml 

echo "Wait until orderer pods are all running..."
while [[ $(kubectl get pods -l name=hlf-orderer -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') == *"False"* ]]; do echo "waiting for orderer pods" && sleep 1; done
OUTPUT=$(kubectl get  pods -l name=hlf-orderer)
echo "====="
echo "${OUTPUT}"
echo "====="

MULTILINE=$(ls \
   -1)
   echo "====="

echo "${MULTILINE}"
echo "====="

if [ -z $(kubectl get  pods -l name=hlf-orderer) ] ; then 
    echo 'Orderer pods does not exist. Please check the error.'
    exit 0
fi 

echo "Wait until peer pods are all running..."
while [[ $(kubectl get pods -l name=hlf-peer -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') == *"False"* ]]; do echo "waiting for peer pods" && sleep 1; done

if [[ $(kubectl get  pods -l name=hlf-peer) == *"No resources found in"* ]] ; then 
    echo 'Peer pods does not exist. Please check the error.'
    exit 0
fi 

# kubectl wait pods -l name=hlf-orderer --for=condition=Ready=true
#  kubectl get  pods -l name=hlf-orderer
 
# we don't check for CA because if peers and orderers are running then CA pods are also running. 

echo "Run channel flow..."
helm template channel-flow/ -f $FOLDER_NAME/network.yaml -f $FOLDER_NAME/crypto-config.yaml -f $FOLDER_NAME/hostAliases.yaml | argo submit - --watch


sleep 5 

echo "Run chaincode flow..."
helm template chaincode-flow/ -f $FOLDER_NAME/network.yaml -f $FOLDER_NAME/crypto-config.yaml  -f $FOLDER_NAME/hostAliases.yaml | argo submit - --watch

