#!/bin/sh
set -e

rm -rf /tmp/ansible-gitlab

git clone https://github.com/${atlantis_github_user}/ansible-gitlab.git /tmp/ansible-gitlab

cp -r /tmp/vars/. /tmp/ansible-gitlab/inventory/production/group_vars/all/
cp -r /tmp/vault_pass/. /tmp/ansible-gitlab/
cp -r /tmp/gitlab_hosts/. /tmp/ansible-gitlab/inventory/production/

cd /tmp/ansible-gitlab
ansible-vault encrypt inventory/production/group_vars/all/vault_plain.yml --vault-password-file .vault_pass --output inventory/production/group_vars/all/vault.yml

rm inventory/production/group_vars/all/vault_plain.yml

ansible-playbook -i inventory/production/hosts.yml deploy-gitlab-vm.yml --vault-password-file .vault_pass