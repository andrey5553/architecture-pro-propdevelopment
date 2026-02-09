# Выполнение спринта 5

Далее во всех заданиях для удобства проверки даются ссылки на файлы png в каталогах Task1-3. Исходные файлы диаграмм .drawio с теми же именами также находятся в тех же каталогах.

## Задание 1. Разработка проверочного листа по безопасности данных

  [mindmap drawio](./Task1/mindmap.drawio)
  [mindmap png](./Task1/mindmap.png)
  [Описание](./Task1/README.md)

## Задание 2. Разработка и заполнение проверочного листа для бизнес-систем

  [Проверочный лист](./Task2/IB.md)

## Задание 3. Внешние интеграции

  [Диаграмма контекста для новых сервисов C4](./Task3/contextDiagram.puml)
  [Доработатка диаграммы контейнеров PropDevelopment с учетом новых сервисов drawio](./Task3/PropDevelopment_С4_model_extended.drawio)
  [Доработатка диаграммы контейнеров PropDevelopment с учетом новых сервисов png](./Task3/png/PropDevelopment_С4_model_extended.png)

## Задание 4. Защита доступа к кластеру Kubernet
  [Роли и их полномочия при работе с Kubernetes](./Task4/roles.md)
    
  [Cкрипт для создания роли](./Task4/scripts/role-cluster-viewer.yaml)
  [Cкрипт для создания роли](./Task4/scripts/role-cluster-editor.yaml)
  [Cкрипт для создания роли](./Task4/scripts/role-cluster-admin.yaml)

  [Cкрипт для создания пользователя `devops-ivan-ivanych` и его привязке к роли `cluster-admin`](./Task4/scripts/add-user-cluster-admin.yaml)
  [Cкрипт для создания пользователя `qa-semen-semenovich` и его привязке к роли `cluster-viewer`](./Task4/scripts/add-user-cluster-viewer.yaml)

  [Powershell скрипты для запуска yaml нотаций k8s](./Task4/scripts/ps1/)

  Результат создания ролей, пользователей и их привязке к ролям, представлены на скринах:

  [Картинка создание роли cluster-viewer](./Task4/png/создание%20роли%20cluster-viewer.png)
  [Картинка создание роли cluster-admin](./Task4/png/создание%20роли%20cluster-admin.png)

  [Картинка привязка пользователя к роли cluster-viewer](./Task4/png/привязка%20пользователя%20к%20роли%20cluster-viewer.png)
  [Картинка привязка пользователя к роли cluster-admin](./Task4/png/привязка%20пользователя%20к%20роли%20cluster-admin.png)

## Задание 5. Управление трафиком внутри кластера Kubertnetes

  Разворачиваем minikube с подключением политик управления трафиком (использую calico).
  Команды:
    # 1. Пересоздать кластер
    minikube delete
    minikube start --network-plugin=cni --cni=calico
    # 2. Создаем наши сервисе в среде миникуба, а именно выполняем скрипт:
    [Cкрипт для создания тестовых сервисов](./Task5/add_services.sh)
    [Команда запуска в среде powershell](./Task5/ps1/add_services.ps1)
    [Результат развертывания в openlens](./Task5/png/развертывание%204-х%20сервисов%20в%20minikube%20-%20openlens.png)
    [Результат развертывания в среде powershell](./Task5/png/развертывание%204-х%20сервисов%20в%20minikube.png)
    # 3. Создаем политика прохождения трафика между сервисами:
    [Cкрипт для создания тестовых сервисов](./Task5/add_politics.sh)
    [Команда запуска в среде powershell](./Task5/ps1/add_politics.ps1)
    [Результат развертывания в openlens](./Task5/png/создание%20сетевых%20политик%20для%20работы%20сервисов.png)
    [Список сетевых политик кластера](./Task5/png/список%20сетевых%20политик%20для%20нашего%20контура.png)
  
  Тестирование сетевых политик
  # 1 Команда для тестирования возможности работы (получения трафика) между front-end-app и back-end-api-app
  kubectl exec -n network-policy-assignment5 front-end-app -- curl -s --connect-timeout 5 http://back-end-api-app:80 
  Результат: успешное получение данных (pass)
  [Успешный результат прохождения трафика](./Task5/png/тест-трафик%20между%20front-end-app%20и%20back-end-api-app%20(pass).png)

  # 2 Команда для тестирования возможности работы (получения трафика) между admin-front-end-app и admin-back-end-api-app
  kubectl exec -n network-policy-assignment5 admin-front-end-app -- curl -s --connect-timeout 5 http://admin-back-end-app:80 
  Результат: успешное получение данных (pass)
  [Успешный результат прохождения трафика](./Task5/png/тест-трафик%20между%20admin-front-end-app%20и%20admin-back-end-app%20(pass).png)

  # 3 Команда для тестирования возможности работы (получения трафика) между front-end-app и admin-back-end-api-app
  kubectl exec -n network-policy-assignment5 front-end-app -- curl -s --connect-timeout 5 http://admin-back-end-app:80
  Результат: command terminated with exit code 28 (Код 28 — это CURLE_OPERATION_TIMEDOUT, то есть curl 
  не смог установить соединение в течение 5 секунд (таймаут --connect-timeout 5). Трафик заблокирован политиками!) (fail)
  [Ошибка получения трафика](./Task5/png/тест-трафик%20между%20front-end-app%20и%20admin-back-end-app%20(fail).png)

## Задание 6. Аудит активности пользователей и обнаружение инцидентов
  
  [Настройка политик аудита в кластере minikube приведена в файле](/Task6/README.md)

  Результаты:
  [Краткий отчёт по выявленным событиям](/Task6/analysis.md)
  [Выжимка из audit.log](/Task6/audit-extract-20260209_185624.json)
  [Скрипт фильтрации](/Task6/filter.sh)

  [Общая статистика анализа логов для аудита](/Task6/png/общая%20статистика%20анализа%20логов%20для%20аудита.png)
  [АНАЛИЗ HIGH-СОБЫТИЙ АУДИТА](/Task6/high-events-analysis.md)

  [Запуск скрипта с симуляцией действий](/Task6/png/запуск%20скрипта%20с%20симуляцией%20действий.png)
  


  


  




