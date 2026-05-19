# Сборка проекта Redmine
Оригинальный проект: https://www.redmine.org/
Образ: https://hub.docker.com/_/redmine
В redmine установлены:
- https://github.com/gagnieray/opale симпатичная тема для работы
- https://github.com/jgraichen/redmine_dashboard - канбан доска.
- https://github.com/vanzhiganov/redmine-forgejo-webhook - плагин для связки с gitea

### Старт проекта
```
docker-compose up -d
```
Переходим на http://127.0.0.1:3000/

```
Логин: admin
Пароль: admin
```
