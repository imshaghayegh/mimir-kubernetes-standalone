# Architecture

This repository deploys **only Grafana Mimir**. It does **not** deploy Kafka, Fluent Bit, Prometheus or Grafana.

```text
metrics producers (external to this repo)
      |  Prometheus remote_write + X-Scope-OrgID
      v
mimir-gateway.mimir.svc.cluster.local:80/api/v1/push
      -> distributor -> ingesters (WAL on PVC)
                       -> S3-compatible object store / MinIO (lab only)
      query /prometheus/api/v1/query
      -> query-frontend -> querier -> store-gateway / ingesters
```

The Helm chart also includes control-plane and maintenance components such as compactor, ruler, alertmanager, cache, and memberlist connectivity. Exact workloads vary by chart version and values.

Classic mode is selected so Mimir has no operational dependency on Kafka. Modern Mimir defaults to ingest-storage (Kafka-backed); evaluate a future upgrade separately.

## Ports
- Gateway HTTP: typically port `80` via `mimir-gateway` Service.
- Internal Mimir HTTP/gRPC, memberlist and other ports are chart-managed. Do not expose them publicly by default.

## Tenancy
Use `X-Scope-OrgID` on writes and queries when `multitenancy_enabled: true`. Configure authentication and tenant mapping at your ingress/gateway; a tenant header alone is NOT authentication.
