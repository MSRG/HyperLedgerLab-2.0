#!/bin/bash


# exit when any command fails
set -e
# set -x

network_yaml=$1
crypto_config_yaml=$2
chaincode=$3
peer=$4

echo $chaincode
echo $peer

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

