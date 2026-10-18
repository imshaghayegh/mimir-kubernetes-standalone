#!/usr/bin/env bash
set -euo pipefail
for b in kubectl helm curl; do command -v "$b" >/dev/null || { echo "Missing binary: $b" >&2; exit 1; }; done
kubectl cluster-info
kubectl get nodes -o wide
kubectl get storageclass
helm version
printf '\nEnsure sufficient nodes/resources, DNS, PVC provisioning, and object storage before install.\n'
