# nginx-reverse-emby PostgreSQL Design

## Goal

Rewrite the `charts/nginx-reverse-emby` Helm chart so it matches the provided Docker Compose setup while supporting both an embedded PostgreSQL database by default and an external PostgreSQL database for production deployments.

## Architecture

The chart will deploy two logical components by default:

1. The `nginx-reverse-emby` application Deployment, Service, PVC, and optional Ingress/HTTPRoute resources.
2. An embedded PostgreSQL Deployment, Service, and PVC controlled by `postgresql.enabled`.

The application remains the public-facing component. It exposes the management panel on `service.panelPort` and reverse-proxy traffic on `service.proxyPort`. It mounts persistent panel data at `/opt/nginx-reverse-emby/panel/data`.

PostgreSQL uses `postgres:17-alpine` by default, listens on port 5432, stores data at `/var/lib/postgresql/data`, and receives its initialization values from chart-generated Secret keys.

## Configuration Model

`values.yaml` will keep the repository's standard ordering and add structured sections for application and database settings:

- `panel.role`, `panel.backendHost`, `panel.backendPort`
- `panel.enableLocalAgent`, `panel.localAgentId`, `panel.localAgentName`
- `database.driver`, `database.dsn`, `database.host`, `database.port`, `database.name`, `database.user`, `database.password`, `database.sslMode`
- `postgresql.enabled`, `postgresql.image`, `postgresql.service`, `postgresql.auth`, `postgresql.persistence`, `postgresql.resources`, `postgresql.startupProbe`, `postgresql.livenessProbe`, `postgresql.readinessProbe`
- `dependencyAutoConfig.enabled`

When `dependencyAutoConfig.enabled` is true, templates generate app environment automatically from structured values. User-provided `.Values.env` and `.Values.secrets` are merged last and override generated values.

## Generated Environment

The ConfigMap will contain non-sensitive values:

- `PANEL_ROLE`
- `PANEL_BACKEND_HOST`
- `PANEL_BACKEND_PORT`
- `NRE_ENABLE_LOCAL_AGENT`
- `NRE_LOCAL_AGENT_ID`
- `NRE_LOCAL_AGENT_NAME`
- `NRE_DATABASE_DRIVER`

The Secret will contain sensitive values:

- `API_TOKEN`
- `MASTER_REGISTER_TOKEN`
- `NRE_DATABASE_DSN`
- `POSTGRES_DB`
- `POSTGRES_USER`
- `POSTGRES_PASSWORD`

DSN selection order:

1. If `database.dsn` is set, use it.
2. If `postgresql.enabled` is true, generate a DSN pointing to the embedded PostgreSQL Service.
3. If `postgresql.enabled` is false, generate a DSN from the external `database.*` connection fields.

Database passwords stay in Secret data, not ConfigMap data.

## Kubernetes Templates

Existing templates stay responsible for the main app:

- `deployment.yaml`: app Deployment with checksum rollout annotations, optional command/args, `envFrom`, probes, persistence, and `Recreate` strategy when persistence or extra volumes are enabled.
- `service.yaml`: app Service with panel and proxy ports.
- `ingress.yaml` and `httproute.yaml`: proxy traffic exposure.
- `panel-ingress.yaml` and `panel-httproute.yaml`: management panel exposure.
- `configmap.yaml` and `secret.yaml`: generated app configuration plus user overrides.

New PostgreSQL templates:

- `postgresql-deployment.yaml`: embedded PostgreSQL workload, enabled only when `postgresql.enabled` is true.
- `postgresql-service.yaml`: internal database Service, enabled only when `postgresql.enabled` is true.
- `postgresql-pvc.yaml`: database PVC, enabled only when `postgresql.enabled` is true and no existing claim is configured.

Helpers will include PostgreSQL-specific names and labels so resource names are not hardcoded.

## Validation

The implementation is complete when these commands pass from the repository root:

```bash
helm template my-release charts/nginx-reverse-emby
helm template my-release charts/nginx-reverse-emby --set postgresql.enabled=false --set database.host=postgres.example.internal --set database.password=external-password
helm lint charts/nginx-reverse-emby
helm install my-release charts/nginx-reverse-emby --dry-run --debug
```

The rendered manifests must include the embedded PostgreSQL resources by default and omit them when `postgresql.enabled=false`.
