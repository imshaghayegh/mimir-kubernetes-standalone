#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
NS="${NAMESPACE:-mimir}"
REL="${RELEASE:-mimir}"
VERSION="$(cat .helm-version)"
helm repo add grafana https://grafana.github.io/helm-charts --force-update
helm repo update
kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -
helm upgrade --install "$REL" grafana/mimir-distributed \
  --namespace "$NS" --version "$VERSION" \
  -f values/classic.yaml -f values/lab.yaml \
  --wait --timeout 20m
kubectl get pods,pvc,svc -n "$NS"
echo 'LAB ONLY: access via port-forward, see README.md'
