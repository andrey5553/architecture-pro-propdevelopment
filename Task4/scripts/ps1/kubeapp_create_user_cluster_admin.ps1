cd ..
kubectl apply -f add-user-cluster-admin.yaml

kubectl get serviceaccount devops-ivan-ivanych -n default
kubectl get clusterrolebinding devops-ivan-ivanych-binding

kubectl auth can-i get pods --as=system:serviceaccount:default:devops-ivan-ivanych
kubectl auth can-i list nodes --as=system:serviceaccount:default:devops-ivan-ivanych

