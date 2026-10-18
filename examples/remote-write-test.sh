#!/usr/bin/env bash
set -euo pipefail
cat <<'EOF'
Mimir accepts Prometheus remote_write at:
  http://mimir-gateway.mimir.svc.cluster.local/api/v1/push
If multitenancy is enabled, configure X-Scope-OrgID, e.g. demo.
For an end-to-end write test use a real Prometheus/Alloy sender; arbitrary curl text to /api/v1/push is not valid remote_write protobuf/snappy.
EOF
