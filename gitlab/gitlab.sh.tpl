#!/bin/bash
set -e

helm repo add gitlab https://charts.gitlab.io
helm repo update
helm upgrade --install yc-agent gitlab/gitlab-agent \
    --namespace gitlab-agent-yc-agent \
    --create-namespace \
    --set config.token=${TOKEN_GITLAB_AGENT} \
    --set config.kasAddress=wss://kas.gitlab.com

curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash
sudo apt install gitlab-runner -y
sudo gitlab-runner status
sudo gitlab-runner register --executor shell --url https://gitlab.com --token ${TOKEN_GITLAB_RUNNER} --non-interactive
nohup gitlab-runner run >/dev/null 2>&1 &
sudo usermod -aG docker gitlab-runner


sed -i 's|alexbeznosov/nginx-app:latest|__IMAGE__|g' /home/ubuntu/nginx-app.yml