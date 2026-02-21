Описание последовательных шагов по развертыванию аудита и его оценки в кластере minikube

  # 1 Создание audit-policy.yaml
  # 2 Скрипт симуляции simulate-incident.sh
  # 3 Останавливаем текущий кластер (если запущен) minikube stop
  # 4 Удаляем кластер под чистую minikube delete --all --purge
  # 5 Создаем файл политик аудита 

cat > ~/new-audit-policy.yaml << 'EOF'
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
  - level: RequestResponse
    verbs: ["create", "delete", "update", "patch", "get", "list"]
    resources:
      - group: ""
        resources: ["pods", "secrets", "configmaps", "serviceaccounts", "roles", "rolebindings"]
  - level: Metadata
    resources:
      - group: ""
        resources: ["*"]
EOF

# 5 Создаем директорию mkdir -p ~/.minikube/files/var/lib/minikube/certs/

# 6 Копируем cp ~/new-audit-policy.yaml ~/.minikube/files/var/lib/minikube/certs/

# 7 Записываем файл с политиками аудита 
minikube start \
  --extra-config=apiserver.audit-policy-file=/var/lib/minikube/certs/new-audit-policy.yaml \
  --extra-config=apiserver.audit-log-path=- --extra-config=apiserver.audit-log-format=json

# 8 Создание скрипта с симуляцией действий

mkdir -p ~/minikube-audit && cat > ~/minikube-audit/simulate-incident.sh << 'SIM_END'
#!/bin/bash
echo "=== Начинаем симуляцию подозрительных действий ==="
echo "Время начала: \$(date)"

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
echo "Время окончания: \$(date)"
SIM_END

# 9 Выдаем права на запуск chmod +x ~/minikube-audit/simulate-incident.sh

# 10 Запускаем скрипт симуляции действий ~/minikube-audit/simulate-incident.sh

# 11 [Результат запуска скрипта симулятора действий](./Task6/png/запуск%20скрипта%20с%20симуляцией%20действий.png)

# 12
cat > ~/minikube-audit/analyze-audit.sh << 'ANALYZE_EOF'
#!/bin/bash

AUDIT_LOG="audit-log.txt"
OUT_JSON="audit-extract-$(date +%Y%m%d_%H%M%S).json"

# Если файл не указан, используем audit.log по умолчанию
if [ -z "$AUDIT_LOG" ]; then
    AUDIT_LOG="audit.log"
fi

echo "Анализируем файл: $AUDIT_LOG"
echo "Выходной файл: $OUT_JSON"

jq --argjson severity_filter '["RequestResponse", "Request"]' -s 'map(
  select(
    # Фильтр 1: Все попытки ЧТЕНИЯ СЕКРЕТОВ
    (.objectRef.resource == "secrets" and .verb == "get") or
    
    # Фильтр 2: Любые команды EXEC в поде (подозрительная активность)
    (.objectRef.subresource == "exec") or
    
    # Фильтр 3: Попытки СОЗДАНИЯ РОЛЕЙ/ПРИВЯЗОК РОЛЕЙ (escalation)
    ((.objectRef.resource == "roles" or .objectRef.resource == "rolebindings") and .verb == "create") or
    
    # Фильтр 4: ПОПЫТКИ ДОСТУПА К ЧУВСТВИТЕЛЬНЫМ ЭНДПОИНТАМ API
    (.objectRef.resource == "secrets" and .responseStatus.code >= 400) or
    
    # Фильтр 5: ВЫЗОВЫ ОТ ПОДОЗРИТЕЛЬНЫХ ПОЛЬЗОВАТЕЛЕЙ (например, service accounts)
    (.user.username | test("^system:serviceaccount:|^unknown"))
  )
  # Добавляем вычисляемое поле для удобства чтения
  | . + {_severity: (
        if .objectRef.resource == "secrets" then "HIGH"
        elif .objectRef.subresource == "exec" then "HIGH"
        elif .objectRef.resource == "roles" then "MEDIUM"
        else "LOW"
        end
    )}
)' "$AUDIT_LOG" > "$OUT_JSON"

# Базовая статистика
echo "=== Статистика ==="
jq 'group_by(._severity)[] | {severity: .[0]._severity, count: length}' "$OUT_JSON"
echo "Всего событий: $(jq 'length' "$OUT_JSON")"
ANALYZE_EOF

# 13 Сделать файл исполняемым
chmod +x ~/minikube-audit/analyze-audit.sh

# 14 Получаем результат исполнения скрипта
[Результат запуска скрипта статистики анализа аудита](./Task6/png/общая%20статистика%20анализа%20логов%20для%20аудита.png)

# 15 Анализ HIGH событий в аудите, команда
jq '.[] | select(._severity == "HIGH") | {
  time: .requestReceivedTimestamp,
  user: .user.username,
  verb: .verb,
  resource: .objectRef.resource,
  namespace: .objectRef.namespace,
  name: .objectRef.name,
  status: .responseStatus.code
}' audit-extract-20260209_185624.json

# 15 Анализ HIGH событий в аудите, отчет
[Анализ HIGH событий в аудите, отчет](./Task6/high-events-analysis.md)



