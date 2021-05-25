argo delete --all
helm delete hlf-kube
#delete all PersistenVolumeClaims
kubectl delete pvc --all 