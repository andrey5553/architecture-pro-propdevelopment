cd ..
kubectl apply -f role-cluster-admin.yaml

Write-Host "=== Checking RBAC objects ===" -ForegroundColor Cyan

Write-Host "`n1. ClusterRole:" -ForegroundColor Yellow
kubectl get clusterrole cluster-admin

Write-Host "`n2. ClusterRoleBinding:" -ForegroundColor Yellow
kubectl get clusterrolebinding admin-binding

Write-Host "`n3. ClusterRole details:" -ForegroundColor Yellow
kubectl describe clusterrole cluster-admin | Select-String -Pattern "Name:|Rules:" -Context 0,3

Write-Host "`n4. Binding details:" -ForegroundColor Yellow
kubectl describe clusterrolebinding admin-binding | Select-String -Pattern "Name:|Role:|Subjects:" -Context 0,3
