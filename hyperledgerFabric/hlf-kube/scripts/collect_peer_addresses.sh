#!/bin/bash


# exit when any command fails
set -e
set -x

echo $(yq --version)
anchor_peers=$(yq eval -j '.Organizations[] | select (.Name == "'$(echo $orgID)'") | .AnchorPeers' "$configtx_yaml")



set +x
