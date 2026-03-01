# cognee Helm Chart

This chart deploys the Cognee API backend and mirrors the service profiles from upstream `docker-compose.yml`:

- `cognee` (core API)
- optional `postgres`
- optional `chromadb`
- optional `neo4j`

## Prerequisites

- Kubernetes 1.24+
- Helm 3.12+
- LLM API key (`secrets.LLM_API_KEY`)

## Install

```bash
helm install cognee ./charts/cognee \
  --set secrets.LLM_API_KEY=your-api-key
```

## Upgrade

```bash
helm upgrade cognee ./charts/cognee
```

## Uninstall

```bash
helm uninstall cognee
```

## Required values

```yaml
secrets:
  LLM_API_KEY: "your-api-key"
```

## Core behavior

- App config via ConfigMap (`values.env`)
- Sensitive config via Secret (`values.secrets`)
- Deployment checksum rollout on config/secret changes
- Probes on `/health`
- Default persistent data volume mounted at `/var/lib/cognee`

## Key values

| Key | Description | Default |
|-----|-------------|---------|
| `image.repository` | Cognee image | `cognee/cognee` |
| `image.tag` | Image tag | `Chart.appVersion` (`0.5.3`) |
| `service.port` | API port | `8000` |
| `env.REQUIRE_AUTHENTICATION` | Require API auth | `"true"` |
| `env.ENABLE_BACKEND_ACCESS_CONTROL` | Access control | `"true"` |
| `env.LLM_MODEL` | LLM model | `openai/gpt-5-mini` |
| `env.LLM_ENDPOINT` | Custom OpenAI-compatible endpoint | not set |
| `env.VECTOR_DB_PROVIDER` | Vector DB provider | `lancedb` |
| `dependencyAutoConfig.enabled` | Auto-wire in-chart dependencies to env vars | `true` |
| `persistence.enabled` | API PVC | `true` |

## Optional dependency profiles

Enable compose-like profiles through values:

```yaml
postgres:
  enabled: true

chromadb:
  enabled: false

neo4j:
  enabled: false
```

When `dependencyAutoConfig.enabled=true`, enabling in-chart services auto-injects common connection env vars into Cognee:

- `postgres.enabled` -> `DB_PROVIDER`, `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USERNAME`, `DB_PASSWORD`
- `chromadb.enabled` -> `VECTOR_DB_PROVIDER=chromadb`, `VECTOR_DB_URL`
- `neo4j.enabled` -> `GRAPH_DATABASE_PROVIDER=neo4j`, `GRAPH_DATABASE_URL`, graph credentials

## Example: postgres + pgvector

```yaml
postgres:
  enabled: true

env:
  VECTOR_DB_PROVIDER: "pgvector"
  VECTOR_DB_HOST: "cognee-postgres"
  VECTOR_DB_PORT: "5432"
  VECTOR_DB_NAME: "cognee_db"

secrets:
  LLM_API_KEY: "your-api-key"
```

## Example: chromadb profile

```yaml
chromadb:
  enabled: true

env:
  VECTOR_DB_PROVIDER: "chromadb"
```

## Multi-user architecture (recommended)

Run this chart as centralized Cognee API, then let each user run local MCP with per-user token:

- backend: this `cognee` chart
- local MCP: `python src/server.py --api-url ... --api-token ...`
- keep `REQUIRE_AUTHENTICATION=true` and `ENABLE_BACKEND_ACCESS_CONTROL=true`

## Health endpoints

- `/health`
- `/health/detailed`

## Validate

```bash
helm template my-release ./charts/cognee
helm lint ./charts/cognee
helm install my-release ./charts/cognee --dry-run --debug
```
