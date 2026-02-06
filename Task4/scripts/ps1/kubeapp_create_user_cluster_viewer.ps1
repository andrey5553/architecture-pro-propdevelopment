cd ..
kubectl apply -f add-user-cluster-viewer.yaml

kubectl get serviceaccount qa-semen-semenovich -n default
kubectl get clusterrolebinding qa-semen-semenovich-binding

kubectl auth can-i get pods --as=system:serviceaccount:default:qa-semen-semenovich
kubectl auth can-i list nodes --as=system:serviceaccount:default:qa-semen-semenovich

