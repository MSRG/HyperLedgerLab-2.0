#!/bin/bash

# creates genesis block and certificates
# and copies them to hlf-kube/ folder

if [ "$#" -lt 2 ]; then
   echo "usage: init.sh <project_folder> <chaincode_folder> [create_genesis_block]"
   exit 2
fi

# exit when any command fails
set -e

project_folder=$1
chaincode_folder=$2
create_genesis_block=${3:-true}

current_folder=$(pwd)

cd $project_folder
config_file=./network.yaml

rm -rf crypto-config
rm -rf channel-artifacts

mkdir -p channel-artifacts

# generate certs
echo "-- creating certificates --"
cryptogen generate --config ./crypto-config.yaml --output crypto-config

if [ "$create_genesis_block" == true ]; then
    # generate genesis block
    echo "-- creating genesis block --"
    genesisProfile=$(yq eval '.network.genesisProfile' $config_file )
    systemChannelID=$(yq eval '.network.systemChannelID' $config_file )
    configtxgen -profile $genesisProfile -channelID $systemChannelID -outputBlock ./channel-artifacts/genesis.block
else
    echo "-- skipping genesis block creation --"
fi

# copy stuff hlf-kube folder (as helm charts cannot access files outside of chart folder)
# see https://github.com/helm/helm/issues/3276#issuecomment-479117753
cd $current_folder

rm -rf hlf-kube/crypto-config
rm -rf hlf-kube/channel-artifacts

cp -r $project_folder/crypto-config hlf-kube/
cp -r $project_folder/channel-artifacts hlf-kube/

cp -r $project_folder/configtx.yaml hlf-kube/

# prepare chaincodes
./prepare_chaincodes.sh $project_folder $chaincode_folder
