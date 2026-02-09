# ~/minikube-audit/simulate-incident.sh
#!/bin/bash
echo "=== Начинаем симуляцию подозрительных действий ==="
echo "Время начала: $(date)"

# 1. Создание подозрительного конфигмапа
echo -e "\n1. Создание подозрительного configmap..."
kubectl create configmap suspicious-config --from-literal=password=secret123

# 2. Создание подозрительного пода
echo -e "\n2. Создание подозрительного pod..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: suspicious-pod
  labels:
    app: test
spec:
  containers:
  - name: nginx
    image: nginx:alpine
    ports:
    - containerPort: 80
EOF

# 3. Попытка доступа к секретам (обычно запрещено)
echo -e "\n3. Попытка листинга секретов в kube-system..."
kubectl get secrets -n kube-system 2>&1 | head -5

# 4. Создание serviceaccount
echo -e "\n4. Создание serviceaccount..."
kubectl create serviceaccount test-sa

# 5. Попытка выполнения команды в поде
echo -e "\n5. Попытка выполнения команды в поде..."
kubectl exec suspicious-pod -- ls /etc 2>&1 | head -3

# 6. Удаление ресурсов
echo -e "\n6. Удаление созданных ресурсов..."
kubectl delete pod suspicious-pod
kubectl delete configmap suspicious-config
kubectl delete serviceaccount test-sa

echo -e "\n=== Симуляция завершена ==="
echo "Время окончания: $(date)"
