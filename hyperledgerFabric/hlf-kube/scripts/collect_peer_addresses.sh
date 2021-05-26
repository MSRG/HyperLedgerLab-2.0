#!/bin/bash


# exit when any command fails
set -e
# set -x

network_yaml=$1
crypto_config_yaml=$2
chaincode=$3

echo $(cat $network_yaml) 
echo $(yq --version)
output=""
echo $chaincode
orgIDs=$(yq eval '.network | .chaincodes[] | select (.name == "'$(echo $chaincode)'") | .orgs[]' "$network_yaml")
echo $orgIDs    
array=($orgIDs)

for f in "${array[@]}"
do
	echo  "--- $f ---  "
done

orgID="Org1"

domain=$(yq eval '.PeerOrgs[] | select (.Name == "'$(echo $orgID)'") | .Domain' "$crypto_config_yaml")
output="$output --peerAddresses $domain --tlsRootCertFiles /etc/hyperledger/fabric/tls/$domain/ca.crt"
echo $domain    
echo $output
# set +x
