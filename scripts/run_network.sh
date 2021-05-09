#!/usr/bin/env bash

set -x
# Go to hyperledgerFabric folder
cd `dirname $0`/hyperledgerFabric

 ./init.sh ./scaled-raft-no-tls/ ./chaincode/

helm install hlf-kube ./hlf-kube/ -f scaled-raft-no-tls/network.yaml -f scaled-raft-no-tls/crypto-config.yaml --set orderer.cluster.enabled=true --set peer.launchPods=false --set orderer.launchPods=false 

 ./collect_host_aliases.sh ./scaled-raft-no-tls/

helm upgrade hlf-kube ./hlf-kube/ -f scaled-raft-no-tls/network.yaml -f scaled-raft-no-tls/crypto-config.yaml -f scaled-raft-no-tls/hostAliases.yaml --set orderer.cluster.enabled=true

kubectl get po --output=wide -w
set +x