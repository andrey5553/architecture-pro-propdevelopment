# Отчёт по результатам анализа Kubernetes Audit Log

## Подозрительные события

1. Доступ к секретам:
   Команда: jq 'select(.objectRef.resource=="secrets" and .verb=="get")' audit-log.txt > ~/minikube-audit/secrets-access.txt
   [Выгрузка](/check_audit_results/secrets-access.txt)

   ## 1.1 Кто совершал доступ
   **Пользователь:** `kubernetes-admin`  
   **Группы:** `kubeadm:cluster-admins`, `system:authenticated`  
   **Агент:** `kubeadm/v1.35.0` (инструмент управления кластером)

   ## 1.2 Где происходил доступ
   **Ресурс:** `secrets/bootstrap-token-tv8mov`  
   **Пространство имён:** `kube-system`  
   **IP-источник:** `192.168.49.2` (внутренний IP кластера Minikube)

   ## 1.3 Почему это подозрительно
   **Статус:** `404 Not Found` - попытка доступа к несуществующему секрету  
   **Контекст:** Bootstrap-токены обычно временные и автоматически удаляются через 24 часа

   **Оценка риска:** НИЗКИЙ  
   **Причина:** Это стандартная системная проверка kubeadm, а не вредоносная активность. Пользователь имеет легитимные права (ClusterRole `cluster-admin`).

2. Привилегированные поды:
Команда: 
jq 'select(
  .objectRef.resource=="pods" and 
  .verb=="create" and 
  .requestObject and 
  .requestObject.spec and 
  .requestObject.spec.containers and 
  (.requestObject.spec.containers[]? | objects | .securityContext.privileged==true)
)' audit-log.txt > ~/minikube-audit/privileges-access.txt
   [Выгрузка](/check_audit_results/privileges-access.txt)

   ## 1. Кто создал privileged-контейнер
   **Пользователь:** `system:serviceaccount:kube-system:daemon-set-controller`  
   **Тип:** Системный Service Account контроллера DaemonSet  
   **Агент:** `kube-controller-manager/v1.35.0` (ядро Kubernetes)

   ## 2. Что было создано
   **Под:** `kube-system/kube-proxy-dzt4b`  
   **Компонент:** `kube-proxy` (сетевой прокси кластера)  
   **Контейнер:** `registry.k8s.io/kube-proxy:v1.35.0`

   **Привилегии:** `securityContext.privileged: true`  
   **Сеть:** `hostNetwork: true` (использует сеть хоста)  
   **Тома:** Доступ к `/lib/modules`, `/run/xtables.lock` (хостовые пути)

   ## 3. Почему это КРИТИЧЕСКИ
   **privileged=true даёт:**
   1. **Полный root-доступ** ко всей ноде
   2. **Обход всех изоляций** Docker/Kubernetes
   3. **Монтирование любых устройств** хоста
   4. **Изменение сетевых настроек** на уровне ядра

   **kube-proxy требует privileged потому что:**
   • Манипулирует iptables/nftables (сетевая фильтрация)
   • Работает с сетевым стеком Linux на уровне ядра
   • Требует доступа к `/lib/modules` для загрузки модулей ядра

   ## ОЦЕНКА РИСКА:
   - **В production:** КРИТИЧЕСКИЙ (но необходим для работы кластера)
   - **В вашем случае:** НОРМА (стандартный системный компонент)


3. Использование kubectl exec в чужом поде:
   Команда: jq 'select(.verb=="create" and .objectRef.subresource=="exec")' audit-log.txt > ~/minikube-audit/aliens-access.txt
   [Выгрузка](/check_audit_results/aliens-access.txt)
   
   ## 1. Кто совершал exec
   **Пользователь:** `minikube-user`  
   **Группы:** `system:masters` (административные права)  
   **Агент:** `kubectl/v1.35.0` (ручная команда через kubectl)  
   **IP-источник:** `192.168.49.1` (хостовая машина Minikube)

   ## 2. Где происходил exec
   **Под:** `default/suspicious-pod`  
   **Контейнер:** `nginx`  
   **Команда:** `ls /etc` (просмотр содержимого директории /etc)

   ## 3. Почему это подозрительно
   **Высокий риск:**
   1. **Прямой доступ к контейнеру** - exec дает полный shell-доступ
   2. **Исследование файловой системы** - `/etc` содержит конфиги, пароли, ключи
   3. **Имя пода `suspicious-pod`** - указывает на тестовую/подозрительную активность
   4. **Статус 101** - Switching Protocols, означает установку WebSocket-соединения для интерактивной сессии

   ## ОЦЕНКА РИСКА:
   - **В production:** Критический инцидент, требующий немедленного расследования
   - **В вашем случае:** Это запланированная тестовая активность (simulate-incident.sh)


4. Создание RoleBinding с правами cluster-admin:
Команда:
jq 'select(
  (.objectRef.resource=="clusterrolebindings" or .objectRef.resource=="rolebindings") and
  .verb=="create" and
  (.requestObject.roleRef.name | test("admin|cluster-admin|edit|view|privileged"))
)' audit-log.txt > ~/minikube-audit/rolebindings-access.txt
[Выгрузка](/check_audit_results/rolebindings-access.txt)

   ## РЕЗУЛЬТАТЫ ПРОВЕРКИ:
   **CRITICAL PASS:** Не обнаружено создание RoleBinding/ClusterRoleBinding с правами:
   - `cluster-admin` (полный контроль над кластером)
   - `admin` (права администратора в namespace)
   - `edit` (права на изменение ресурсов)
   - `view` (права на просмотр)
   - `privileged` (привилегированный доступ)

   ## ЧТО ЭТО ЗНАЧИТ:
   1. **Нет эскалации привилегий** через RBAC
   2. **Не создавались** backdoor-привязки для атакующих
   3. **Кластер не скомпрометирован** через манипуляции с правами

5. Удаление audit-policy.yaml:
   Команда:
   grep -i 'audit-policy' audit-log.txt > ~/minikube-audit/change-audit-access.txt
   [Выгрузка](/check_audit_results/change-audit-access.txt)

   Что нашли:
   Изменён путь к политике: /var/lib/minikube/certs/new-audit-policy.yaml
   Сделано через ConfigMap kubeadm-config (kube-system)
   API-сервер перезапущен с новыми параметрами

   Кто изменил:
   kubernetes-admin → создал ConfigMap с конфигурацией
   system:node:minikube (kubelet) → перезапустил kube-apiserver

   ## ЧТО ЭТО ЗНАЧИТ:
   В вашем случае: НИЗКИЙ (штатная настройка Minikube)
   В production: ВЫСОКИЙ (8/10) - позволяет отключить аудит/скрыть атаки
   ### Злоумышленник может получить полный доступ к кластеру, что означает необходимость изменений.


#### В ходе анализа обнаружены СТАНДАРТНЫЕ ОПЕРАЦИИ Kubernetes, которые
   в PRODUCTION требуют контроля, но в ТЕСТОВОЙ СРЕДЕ являются нормой:

   1. Системные проверки устаревших bootstrap-токенов (не атака)
   2. Автоматическое создание системных компонентов с privileged (kube-proxy)
   3. Тестовые exec-команды от аккаунта Minikube (симуляция)

   Критических компрометаций безопасности НЕ ОБНАРУЖЕНО.

#### Рекомендуется:

* Ограничить доступ к критическим секретам кластера
* Внедрить политику PodSecurity для контроля привилегированных подов
* Пересмотреть политику RBAC и удалить пользователей из группы system:masters
* Настроить мониторинг подозрительных действий в кластере
