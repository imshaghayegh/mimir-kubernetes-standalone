#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
VERSION="$(cat .helm-version)"
helm repo add grafana https://grafana.github.io/helm-charts --force-update
helm repo update
mkdir -p rendered
helm template mimir grafana/mimir-distributed --version "$VERSION" \
  -n mimir -f values/classic.yaml -f values/lab.yaml > rendered/lab.yaml
helm lint grafana/mimir-distributed --version "$VERSION" -f values/classic.yaml -f values/lab.yaml
echo 'Rendered manifests: rendered/lab.yaml (ignored by git). Inspect resource count, PVCs and security before deploy.'
