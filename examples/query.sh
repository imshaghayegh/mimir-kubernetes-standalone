#!/usr/bin/env bash
set -euo pipefail
BASE="${MIMIR_URL:-http://127.0.0.1:18080}"
TENANT="${TENANT:-demo}"
curl -fsSG "$BASE/prometheus/api/v1/query" -H "X-Scope-OrgID: $TENANT" --data-urlencode 'query=up'
