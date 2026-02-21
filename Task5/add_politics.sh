#!/bin/bash

POLICY_FILE="non-admin-api-allow.yaml"

echo ""
echo "Применение сетевой политики из файла '${POLICY_FILE}'"
kubectl apply -f ${POLICY_FILE}
echo "Сетевая политика применена."
echo ""

echo "Проверка сетевой связности"
echo "Политики применены. Ожидание несколько секунд для их вступления в силу..."
sleep 5


# Для очистки ресурсов 
#kubectl delete namespace ${NAMESPACE}

