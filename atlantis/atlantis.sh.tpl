#!/bin/bash
set -e

mkdir -p /tmp/ansible-atlantis/vars

cat > /tmp/ansible-atlantis/vars/vars.yml <<EOF
---
ip_bastion: "${IP_BASTION}"
# Kubernetes
k8s_namespace: "atlantis"

# Atlantis
atlantis_image: "ghcr.io/runatlantis/atlantis:latest"
atlantis_replicas: 1
atlantis_port: 4141
atlantis_nodeport: "${NODEPORT}"

# Ресурсы
atlantis_resources:
  requests:
    memory: "512Mi"
    cpu: "250m"
  limits:
    memory: "2Gi"
    cpu: "1000m"

# GitHub
atlantis_github_user: "${ATLANTIS_GITHUB_USER}"
atlantis_repo_allowlist: "${ATLANTIS_REPO_ALLOWLIST}"
github_repo: "diplom"  
atlantis_webhook_url: "http://${IP_BASTION}:${ATLANTIS_PORT}/events"
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
s3_bucket_name: "${S3_BUCKET_NAME}"
s3_endpoint: "${S3_ENDPOINT}"

# Пути к файлам кредов на бастионе
yc_key_file_path: "${YC_KEY_FILE_PATH_BASTION}"
s3_credentials_file_path: "${S3_CREDENTIALS_FILE_PATH_BASTION}"
ssh_public_key_path: "${SSH_PUBLIC_KEY_PATH_BASTION}"

terraformrc_file_path: "${TERRAFORMRC_BASTION}"

# Yandex Cloud (публичные ID)
cloud_id: "${CLOUD_ID}"
folder_id: "${FOLDER_ID}"
EOF


cat > /tmp/ansible-atlantis/vars/vault.yml <<EOF
---
# GitHub
atlantis_github_token: "${ATLANTIS_GITHUB_TOKEN}"
atlantis_webhook_secret: "${ATLANTIS_WEBHOOK_SECRET}"

# MySQL
mysql_root_password: "R00t_P@ssw0rd!"
mysql_password: "Atl@nt1s_DB_P@ssw0rd!"
EOF

git clone https://github.com/StudentIrgups/ansible-atlantis.git /tmp/ansible-atlantis

cd /tmp/ansible-atlantis
ansible-playbook deploy-atlantis.yml -e @vars/vars.yml -e @vars/vault.yml
