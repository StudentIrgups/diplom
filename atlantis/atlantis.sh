#!/bin/bash
echo $RANDOM | md5sum | head -c 20; echo

helm repo add runatlantis https://runatlantis.github.io/helm-charts
helm repo update

kubectl create namespace atlantis --dry-run=client -o yaml | kubectl apply -f -
kubectl -n atlantis create secret generic yandex-key-secret --from-file=/home/ubuntu/authorized-key-diplom.json --dry-run=client -o yaml | kubectl apply -f -
kubectl -n atlantis create secret generic s3-key-secret --from-file=/home/ubuntu/credentials --dry-run=client -o yaml | kubectl apply -f -
kubectl -n atlantis create secret generic pub-key-secret --from-file=/home/ubuntu/id_rsa.pub --dry-run=client -o yaml | kubectl apply -f -
kubectl -n atlantis create secret generic atlantis-vcs-secrets \
   --from-literal=github_token="${GITHUB_TOKEN}" \
#   --from-literal=github_secret="${SECRET}" \
   --dry-run=client -o yaml | kubectl apply -f -

kubectl -n atlantis create secret generic atlantis-secrets-env \
  --from-literal=token="${GITHUB_TOKEN}" \
#  --from-literal=secret="${SECRET}" \
  --from-literal=db_host="${DB_HOST}" \
  --from-literal=db_user="${DB_USER}" \
  --from-literal=db_password="${DB_PASSWORD}" \
  --from-literal=db_name="${DB_NAME}" \
  --from-literal=mysql_root_password="${MYSQL_ROOT_PASSWORD}" \
  #--from-literal=token_gitlab_agent="${TOKEN_GITLAB_AGENT}" \
  #--from-literal=token_gitlab_runner="${TOKEN_GITLAB_RUNNER}" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n atlantis create configmap atlantis-terraformrc --from-file=.terraformrc=/home/ubuntu/.terraformrc --dry-run=client -o yaml | kubectl apply -f -

cat <<EOF > value.yaml
orgAllowlist: ${REPOS}

github:
  user: ${GITHUB_USERNAME}
vcsSecretName: atlantis-vcs-secrets

service:
  type: NodePort
  port: 80
  targetPort: 4141
  nodePort: 32000

atlantisUrl: ${PUBLIC_IP}:32000

volumeClaim:
  enabled: true
  size: 6Gi
  storageClassName: "local-path"
  accessModes:
    - ReadWriteOnce
environmentSecrets:
  - name: token
    secretKeyRef:
      name: atlantis-secrets-env
      key: token
  - name: db_host
    secretKeyRef:
      name: atlantis-secrets-env
      key: db_host
  - name: db_user
    secretKeyRef:
      name: atlantis-secrets-env
      key: db_user
  - name: db_password
    secretKeyRef:
      name: atlantis-secrets-env
      key: db_password
  - name: db_name
    secretKeyRef:
      name: atlantis-secrets-env
      key: db_name
  - name: mysql_root_password
    secretKeyRef:
      name: atlantis-secrets-env
      key: mysql_root_password

environment:
  yc_cloud_id: ${CLOUD_ID}
  yc_folder_id: ${FOLDER_ID}
  url: ${PUBLIC_IP}
  username: ${GITHUB_USERNAME}
  repo_github: ${REPOS}

extraVolumes:
  - name: yandex-key-volume
    secret:
      secretName: yandex-key-secret
      items:
        - key: authorized-key-diplom.json
          path: authorized-key-diplom.json
  - name: s3-key-volume
    secret:
      secretName: s3-key-secret
      items:
        - key: credentials
          path: credentials
  - name: pub-key-volume
    secret:
      secretName: pub-key-secret
      items:
        - key: id_rsa.pub
          path: id_rsa.pub
  - name: terraformrc
    configMap:
      name: atlantis-terraformrc

extraVolumeMounts:
  - name: yandex-key-volume
    mountPath: /home/atlantis/keys
    readOnly: true
  - name: s3-key-volume
    mountPath: /home/atlantis/.aws
    readOnly: true
  - name: pub-key-volume
    mountPath: /home/atlantis/.ssh
    readOnly: true
  - name: terraformrc
    mountPath: /home/atlantis/
    readOnly: true
EOF

helm upgrade --install atlantis runatlantis/atlantis --namespace atlantis -f value.yaml
