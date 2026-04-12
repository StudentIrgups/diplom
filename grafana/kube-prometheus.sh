#!/bin/sh

set -e

cd /tmp

git clone https://github.com/prometheus-operator/kube-prometheus.git

cd kube-prometheus

kubectl apply --server-side -f manifests/setup

kubectl wait \
    --for condition=Established \
    --all CustomResourceDefinition \
    --namespace=monitoring

kubectl apply -f manifests/

kubectl get pods -n monitoring

kubectl -n monitoring delete networkpolicies.networking.k8s.io grafana

kubectl -n monitoring apply -f /tmp/grafana-node-port.yml