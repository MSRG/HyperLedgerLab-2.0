#!/bin/bash

# this script collects peer addresses used with peer lifecycle chaincode commit. 
# This command needs to target the peers of other organizations on the channel to collect their organization endorsement for the definition.
if test "$#" -ne 4; then
   echo "usage: collect_peer_addresses.sh <network.yaml> <crypto_config.yaml> <chaincode_name> <peer>" 
   exit 2
fi


# exit when any command fails
set -e
# set -x

network_yaml=$1
crypto_config_yaml=$2
chaincode=$3
peer=$4

output=""
orgIDs=$(yq eval '.network | .chaincodes[] | select (.name == "'$(echo $chaincode)'") | .orgs[]' "$network_yaml")
array=($orgIDs)

for orgID in "${array[@]}"
do
domain=$(yq eval '.PeerOrgs[] | select (.Name == "'$(echo $orgID)'") | .Domain' "$crypto_config_yaml")
output="$output --peerAddresses $peer.$domain:7051 --tlsRootCertFiles /etc/hyperledger/fabric/tls/$domain/ca.crt"
done
 
echo $output
# set +x

