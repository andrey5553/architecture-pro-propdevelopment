kubectl apply -f role-cluster-viewer.yaml

Write-Host "=== Checking RBAC objects ===" -ForegroundColor Cyan

Write-Host "`n1. ClusterRole:" -ForegroundColor Yellow
kubectl get clusterrole cluster-viewer

Write-Host "`n2. ClusterRoleBinding:" -ForegroundColor Yellow
kubectl get clusterrolebinding viewer-binding

Write-Host "`n3. ClusterRole details:" -ForegroundColor Yellow
kubectl describe clusterrole cluster-viewer | Select-String -Pattern "Name:|Rules:" -Context 0,3

Write-Host "`n4. Binding details:" -ForegroundColor Yellow
kubectl describe clusterrolebinding viewer-binding | Select-String -Pattern "Name:|Role:|Subjects:" -Context 0,3
