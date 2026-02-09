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
