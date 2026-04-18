# Дипломная работа
Для запуска развёртывания инфраструктуры необходимо:

    1. Вытянуть текущий репозиторий;
    2. В корне репозитория создать файл `personal.auto.tfvars` и наполнить его соответствующими переменным(см. [пример](personal.auto.tfvars_example));
    3. Запустить проект коммандой `terraform apply`.


После чего в течении 35 минут будет выполнять cloud init, в следствии чего установтся:
    1. kubespray, развернётся кластер kubernetes;
    2. nginx-app, тестовое приложение;
    3. kube-prometheus, grafana + prometheus;
    4. atlantis, atlantis. Также автоматически добавится webhook для атлантиса;
    5. gitlab, установка GitLab + автоматическая настройка webhoook и GitHub Actions.

## Вопросы диплома:

### 1.
    [Файлы](./) terraform.
    [Репозиторий тестового приложения](https://github.com/StudentIrgups/nginx_index_file.git) nginx + pipeline для автоматической сборки приложения и развёртывания.
    [Репозиторий ansible atlantis](https://github.com/StudentIrgups/ansible-atlantis.git).
    [Репозиторий ansible gitlab](https://github.com/StudentIrgups/ansible-gitlab.git).