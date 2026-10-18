#!/usr/bin/env bash
set -euo pipefail
NS="${NAMESPACE:-mimir}"
REL="${RELEASE:-mimir}"
LOCAL_PORT="${LOCAL_PORT:-18080}"
TENANT="${TENANT:-demo}"
kubectl -n "$NS" get pods,pvc
kubectl -n "$NS" get svc "${REL}-gateway"
echo "Start in another terminal: kubectl -n $NS port-forward svc/${REL}-gateway ${LOCAL_PORT}:80"
echo "Then run: curl -fsS -H 'X-Scope-OrgID: $TENANT' 'http://127.0.0.1:${LOCAL_PORT}/prometheus/api/v1/query?query=up'"
