#!/bin/bash


# exit when any command fails
set -e
# set -x

network_yaml=$1
crypto_config_yaml=$2
peer=$3

set -x
echo "==================="

echo $network_yaml
echo $crypto_config_yaml
echo $peer

echo "==================="

output=""
orgIDs=$(yq eval '.network | .chaincodes[] | select (.name == "'$(echo $chaincode)'") | .orgs[]' "$network_yaml")
array=($orgIDs)

for orgID in "${array[@]}"
do
domain=$(yq eval '.PeerOrgs[] | select (.Name == "'$(echo $orgID)'") | .Domain' "$crypto_config_yaml")
output="$output --peerAddresses $peer.$domain:7051 --tlsRootCertFiles /etc/hyperledger/fabric/tls/$domain/ca.crt"
done
 
echo $output
set +x

