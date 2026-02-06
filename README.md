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

## Задание 4. Защита доступа к кластеру Kubernetes

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
