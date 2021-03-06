#!/usr/bin/env bash
set -x
kubectl delete jobs caliper-manager
kubectl delete jobs caliper-worker
kubectl delete configmap  benchmarks
kubectl delete configmap network
kubectl delete configmap workload
kubectl delete configmap caliper-config  
kubectl delete configmap caliper-report-git

kubectl delete deployment mosquitto
kubectl delete svc mosquitto
set +x
