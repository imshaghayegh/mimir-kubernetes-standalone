# Grafana Mimir on Kubernetes

Independent, GitHub-ready deployment repository for **Grafana Mimir only**, using the official `grafana/mimir-distributed` Helm chart.

## Scope
- **Included:** Helm values, classic-architecture preset, MinIO lab profile, external-S3 production configuration template, preflight, install, validation, smoke tests, and operational docs.
- **Not included:** Kafka, Strimzi, Kafka Exporter, Fluent Bit, Prometheus, or Grafana deployments.
- **No automatic migration of historical Mimir data.**

## Why classic architecture?
Current Mimir Helm releases default to ingest-storage and may deploy a demo Kafka service. This repository explicitly disables ingest-storage and bundled Kafka so **Mimir itself has no Kafka dependency**. This is a deliberate independent-deployment choice; assess the newer ingest-storage architecture for future production use.

## Prerequisites
- Working Kubernetes with DNS and enough schedulable resources.
- Functional dynamic PVC provisioning and a suitable StorageClass.
- `kubectl`, `helm` (3.8+), `curl`.
- External object storage for production.
- Access to Grafana's Helm chart registry/repository and Mimir images.

## Quick start (LAB only)
```bash
./scripts/00-preflight.sh
./scripts/02-validate.sh
./scripts/01-install-lab.sh
kubectl -n mimir get pods,pvc,svc
```

The `.helm-version` file pins the **example** chart version `6.2.0`. Verify its stable availability and compatibility before installation; change this file when deliberately adopting another version, then review the official release notes. We did not run a live Kubernetes/Helm rendering test in this repository's creation environment.

The lab profile uses the chart's bundled MinIO and other chart defaults. It is NOT safe for production or guaranteed to fit a small cluster. Read chart requirements and reserve sufficient resources, StorageClass and PVC capacity.

## Access Mimir gateway
In terminal 1:
```bash
kubectl -n mimir port-forward svc/mimir-gateway 18080:80
```

In terminal 2:
```bash
curl -fsSG 'http://127.0.0.1:18080/prometheus/api/v1/query' \
  -H 'X-Scope-OrgID: demo' --data-urlencode 'query=up'
```

**Empty result is normal** until remote_write ingests samples. A successful query API response only confirms the read path.

## API endpoints
| Action | In-cluster gateway URL |
|---|---|
| Prometheus remote_write | `http://mimir-gateway.mimir.svc.cluster.local/api/v1/push` |
| PromQL instant query | `http://mimir-gateway.mimir.svc.cluster.local/prometheus/api/v1/query` |
| PromQL range query | `http://mimir-gateway.mimir.svc.cluster.local/prometheus/api/v1/query_range` |

Use `X-Scope-OrgID` on both read and write when multi-tenancy is enabled. `X-Scope-OrgID` is not authentication.

## Production deployment
**Do not install production from `values/lab.yaml`.** Read [docs/PRODUCTION.md](docs/PRODUCTION.md), provision durable external S3-compatible object storage and credentials, then create a reviewed HA values file based on [official production recommendations](https://grafana.com/docs/helm-charts/mimir-distributed/latest/run-production-environment-with-helm/) and `values/production-s3.example.yaml`.

Example ONLY (after completing and reviewing your values):
```bash
helm upgrade --install mimir grafana/mimir-distributed \
  -n mimir --create-namespace \
  --version "$(cat .helm-version)" \
  -f values/classic.yaml -f values/production-reviewed.yaml
```
`values/production-reviewed.yaml` is intentionally NOT provided; it must be tailored to your cluster and kept free of inline secrets.

## Operations
```bash
helm status mimir -n mimir
kubectl get pods,pvc,svc -n mimir
kubectl get events -n mimir --sort-by=.lastTimestamp
./scripts/03-smoke-test.sh
```

For diagnostics, read [Troubleshooting](docs/TROUBLESHOOTING.md). Before uninstalling, review retention and backup plan. Lab uninstall requires `CONFIRM_UNINSTALL=yes ./scripts/04-uninstall-lab.sh`.

## Repository tree
```text
.
├── .helm-version
├── .gitignore
├── README.md
├── values/
│   ├── classic.yaml
│   ├── lab.yaml
│   └── production-s3.example.yaml
├── scripts/
│   ├── 00-preflight.sh
│   ├── 01-install-lab.sh
│   ├── 02-validate.sh
│   ├── 03-smoke-test.sh
│   └── 04-uninstall-lab.sh
├── examples/
│   ├── query.sh
│   └── remote-write-test.sh
└── docs/
    ├── ARCHITECTURE.md
    ├── PRODUCTION.md
    └── TROUBLESHOOTING.md
```

## Upstream docs
- [Deploy Mimir using Helm](https://grafana.com/docs/mimir/latest/set-up/helm-chart/)
- [Production with Helm](https://grafana.com/docs/helm-charts/mimir-distributed/latest/run-production-environment-with-helm/)
- [Classic architecture preset](https://github.com/grafana/mimir/blob/main/operations/helm/charts/mimir-distributed/classic-architecture.yaml)
- [Mimir query API](https://grafana.com/docs/mimir/latest/references/http-api/)

## Security
Do not publish credentials, internal domains, tenant secrets or access keys in Git. Restrict Mimir gateway access; tenant headers are not a substitute for authorization.
