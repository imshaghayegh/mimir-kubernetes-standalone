# Production readiness checklist

> The lab profile is NOT production-grade. Do not rename it "production" and deploy unchanged.

1. Choose and pin a **supported stable** chart version; validate against your Kubernetes version and upgrade notes.
2. Start with Grafana's official sizing plans (small/large) and capacity-plan requests/limits and PVCs from ingestion rate, active series, retention, and queries.
3. External, durable S3-compatible storage with **three distinct buckets** for blocks, ruler, alertmanager. Enable versioning/backup, lifecycle, monitoring, and dedicated credentials. Avoid the bundled single-instance MinIO.
4. Deliver object-store credentials using Kubernetes Secrets / External Secrets; inject environment variables into all Mimir components using supported chart settings. Never commit credentials. Check values of `-config.expand-env=true` if environment interpolation is needed.
5. Enable TLS, an authenticated gateway, service-to-service policy and least privilege. `X-Scope-OrgID` is a routing header, not an authorization control.
6. Deploy adequate ingesters / distributors / queriers / store-gateways across independent failure domains. Test AZ/node loss, rescheduling and recovery. Storage backend and WAL PVCs must survive failures.
7. Verify PodDisruptionBudgets, anti-affinity, termination grace, rollout order and upgrades; never replace/delete StatefulSet PVCs casually.
8. Set retention intentionally (blocks TTL), monitor storage usage and compaction. Validate retention behavior independently of any retention policy on object storage.
9. Configure alerting for ingestion failures, query error rate, ring health, compactor failures, object storage errors, WAL / disk utilization and remote-write queue lag.
10. Set up backups, recovery drills, and disaster-recovery runbooks for buckets, configuration, tenant rules and credentials. Restore into a test environment.
11. If you migrate from a running Mimir, migration of historical metrics/tenants is a separate project. This repo creates a fresh instance; it does not import existing blocks.
12. For new larger environments, evaluate **ingest-storage** with production external Kafka; classic mode here avoids Kafka dependency by design.

The production S3 values template is intentionally incomplete and MUST be reviewed against the chosen chart version; it is not an HA guarantee.
