# Инструкция

## Окружение

```bash
kubectl apply -f 01-create-namespace.yaml

kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/v3.21.1/deploy/gatekeeper.yaml

kubectl get pods -n gatekeeper-system

kubectl apply -f gatekeeper/constraint-templates/
kubectl apply -f gatekeeper/constraints/
```

## Небезопасные поды (завершаются ошибкой)
```bash
kubectl apply -f insecure-manifests/01-privileged-pod.yaml --dry-run=server
kubectl apply -f insecure-manifests/02-hostpath-pod.yaml --dry-run=server
kubectl apply -f insecure-manifests/03-root-user-pod.yaml --dry-run=server
```

## Безопасные поды (завершаются успешно)
```bash
kubectl apply -f secure-manifests/01-secure.yaml --dry-run=server
kubectl apply -f secure-manifests/02-secure.yaml --dry-run=server
kubectl apply -f secure-manifests/03-secure.yaml --dry-run=server
```

## Автоматическая проверка
```bash
bash ./verify/verify-admission.sh
bash ./verify/validate-security.sh
```
