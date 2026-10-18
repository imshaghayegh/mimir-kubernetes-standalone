#!/usr/bin/env bash
set -euo pipefail
NS="${NAMESPACE:-mimir}"
REL="${RELEASE:-mimir}"
if [[ "${CONFIRM_UNINSTALL:-}" != "yes" ]]; then
  echo 'Set CONFIRM_UNINSTALL=yes to uninstall. PVCs and object data are not deleted automatically.' >&2
  exit 1
fi
helm uninstall "$REL" -n "$NS"
echo 'PVCs and MinIO object data may remain. Review and manually clean up ONLY if intended.'
