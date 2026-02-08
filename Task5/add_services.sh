#!/bin/bash

NAMESPACE="network-policy-assignment5"
POLICY_FILE="non-admin-api-allow.yaml"

echo "Создание namespace '${NAMESPACE}'"
kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -
echo ""

echo "Развертывание 4-х Nginx сервисов с метками"
kubectl run front-end-app --image=nginx --labels role=front-end --namespace=${NAMESPACE} --expose --port 80
kubectl run back-end-api-app --image=nginx --labels role=back-end-api --namespace=${NAMESPACE} --expose --port 80
kubectl run admin-front-end-app --image=nginx --labels role=admin-front-end --namespace=${NAMESPACE} --expose --port 80
kubectl run admin-back-end-app --image=nginx --labels role=admin-back-end-api --namespace=${NAMESPACE} --expose --port 80

echo "Ожидание готовности подов..."
kubectl wait --for=condition=ready pod -l role -n ${NAMESPACE} --timeout=120s
echo "Все сервисы развернуты."
