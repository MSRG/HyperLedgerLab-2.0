#!/bin/bash

if [ "$#" -lt 1 ]; then
   echo "usage: collect_host_aliases.sh <project_folder> [additional arguments for kubectl]"
   exit 2
fi

# exit when any command fails
set -e

project_folder=$1

kubectl get svc -l addToHostAliases=true \
    -o jsonpath='{"hostAliases:\n"}{range..items[*]}- ip: {.spec.clusterIP}{"\n"}  hostnames: [{.metadata.labels.fqdn}]{"\n"}{end}' \
    "${@:2}" \
    > $project_folder/hostAliases.yaml
    
cat $project_folder/hostAliases.yaml