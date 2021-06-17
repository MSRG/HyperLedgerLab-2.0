#!/usr/bin/env bash

# if [[ $# -eq 0 ]] ; then
#     echo "usage: network_run.sh <configuration_folder>" 
#     exit 2
# fi

FOLDER_NAME=$1
if [ ! -d  $1 ] ; then
    FOLDER_NAME="config/templates"
    # Create config files using helm template
    echo "-- creating config files --"
    helm template config-template/ -f network-configuation.yaml --output-dir .
fi

# Deleting existing network
argo delete --all
helm delete hlf-kube

# Go to hyperledgerFabric folder
cd `dirname $0`/../hyperledgerFabric



# create necessary stuff: crypto-config files, channel-artifacts and chaincode compression 
./init.sh ./$FOLDER_NAME/ ./chaincode/

# Luanch the Raft based Fabric network in broken state
helm install hlf-kube ./hlf-kube/ -f $FOLDER_NAME/network.yaml -f $FOLDER_NAME/crypto-config.yaml --set peer.launchPods=false --set orderer.launchPods=false 

# Collect the host aliases
./collect_host_aliases.sh ./$FOLDER_NAME/

# Update the network with host aliases
helm upgrade hlf-kube ./hlf-kube/ -f $FOLDER_NAME/network.yaml -f $FOLDER_NAME/crypto-config.yaml -f $FOLDER_NAME/hostAliases.yaml 

# Check if pods exist and running
# we don't check for CA because if peers and orderers are running then CA pods are also running. 
echo "Wait until orderer pods are all running..."
while [[  $(kubectl get pods -l name=hlf-orderer -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') == *"False"* ]] || [[ -z $(kubectl get  pods -l name=hlf-orderer) ]] ; do echo "waiting for orderer pods..." && sleep 2; done

echo "Wait until peer pods are all running..."
while [[ $(kubectl get pods -l name=hlf-peer -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') == *"False"* ]] || [[ -z $(kubectl get  pods -l name=hlf-peer) ]] ; do echo "waiting for peer pods..." && sleep 2; done

echo "Run channel flow..."
helm template channel-flow/ -f $FOLDER_NAME/network.yaml -f $FOLDER_NAME/crypto-config.yaml -f $FOLDER_NAME/hostAliases.yaml | argo submit - --watch

sleep 5 

echo "Run chaincode flow..."
helm template chaincode-flow/ -f $FOLDER_NAME/network.yaml -f $FOLDER_NAME/crypto-config.yaml  -f $FOLDER_NAME/hostAliases.yaml | argo submit - --watch

