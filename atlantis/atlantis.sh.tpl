#!/bin/bash
set -e

git clone https://github.com/StudentIrgups/ansible-atlantis.git /tmp/ansible-atlantis

cat > /tmp/ansible-atlantis/vars.yml <<EOF
---
ip_bastion: "${ip_bastion}"
# Kubernetes
k8s_namespace: "atlantis"

# Atlantis
atlantis_image: "ghcr.io/runatlantis/atlantis:latest"
atlantis_replicas: 1
atlantis_port: 4141
atlantis_nodeport: "${nodeport}"

# Ресурсы
atlantis_resources:
  requests:
    memory: "512Mi"
    cpu: "250m"
  limits:
    memory: "2Gi"
    cpu: "1000m"

# GitHub
atlantis_github_user: "${atlantis_github_user}"
atlantis_repo_allowlist: "${atlantis_repo_allowlist}"
github_repo: "diplom"  
atlantis_webhook_url: "http://${ip_bastion}:${atlantis_port}/events"
atlantis_yaml_content: |
  version: 3
  projects:
  - name: default
    dir: .
    workflow: default
    autoplan:
      enabled: true
      when_modified: ["*.tf", "*.tfvars", "*.hcl"]

# MySQL
mysql_database: "atlantis"
mysql_user: "atlantis"

# S3 (публичные)
s3_bucket_name: '${s3_bucket_name}'
s3_endpoint: "${s3_endpoint}"

# Пути к файлам кредов на бастионе
yc_key_file_path: "${yc_key_file_path_bastion}"
s3_credentials_file_path: "${s3_credentials_file_path_bastion}"
ssh_public_key_path: "${ssh_public_key_path_bastion}"

terraformrc_file_path: "${terraformrc_bastion}"

# Yandex Cloud (публичные ID)
cloud_id: "${cloud_id}"
folder_id: "${folder_id}"
EOF


cat > /tmp/ansible-atlantis/vault.yml <<EOF
---
# GitHub
atlantis_github_token: "${atlantis_github_token}"
atlantis_webhook_secret: "${atlantis_webhook_secret}"

# MySQL
mysql_root_password: "R00t_P@ssw0rd!"
mysql_password: "Atl@nt1s_DB_P@ssw0rd!"
EOF

cd /tmp/ansible-atlantis
ansible-playbook deploy-atlantis.yml