# templates/hosts.yml.tpl
---
all:
  hosts:
    gitlab:
      ansible_host: ${gitlab_ip}
      ansible_user: ubuntu