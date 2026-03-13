# firecrawl

Helm chart for deploying Firecrawl on Kubernetes.

This chart is designed to be usable with minimal configuration:

- Built-in `playwright`
- Built-in `nuq-postgres`
- Built-in `valkey`
- Structured DB auth wiring
- Structured values for common runtime config
- Backward-compatible with raw `env` and `secrets`

Current chart metadata:

- Chart version: `0.1.12`
- App version: `latest`

## What This Chart Deploys

By default, this chart deploys:

- `firecrawl`
- `firecrawl-worker`
- `firecrawl-nuq-worker`
- `firecrawl-playwright`
- `firecrawl-nuq-postgres`
- `firecrawl-valkey`

Default auto wiring:

- `PLAYWRIGHT_MICROSERVICE_URL` points to the built-in `playwright`
- `POSTGRES_HOST`, `POSTGRES_PORT`, `POSTGRES_USER`, `POSTGRES_DB` point to the built-in `nuq-postgres`
- `NUQ_DATABASE_URL` is auto-generated from the built-in database settings
- `REDIS_URL` and `REDIS_RATE_LIMIT_URL` point to the built-in `valkey`
- `USE_DB_AUTHENTICATION` comes from `app.useDbAuthentication`
- `SUPABASE_URL`, `SUPABASE_ANON_TOKEN`, and `SUPABASE_SERVICE_TOKEN` come from `supabase.*`
- `TEST_API_KEY` comes from `apiKeys.testApiKey`
- `HOST=0.0.0.0`
- `ENV=production`
- `LOGGING_LEVEL=INFO`
- `IS_KUBERNETES=true`

## Quick Start

```bash
helm install firecrawl charts/firecrawl -n firecrawl --create-namespace
```

Recommended starting point:

```bash
helm install firecrawl charts/firecrawl \
  -n firecrawl \
  --create-namespace \
  -f charts/firecrawl/values-quickstart.example.yaml
```

Validation:

```bash
helm lint charts/firecrawl
helm template firecrawl charts/firecrawl --debug
helm install firecrawl charts/firecrawl --dry-run --debug -n firecrawl --create-namespace
```

## Structured Values

Use these sections first:

- `app`
- `database`
- `supabase`
- `search`
- `apiKeys`
- `playwright`
- `valkey`

Keep `env` and `secrets` for:

- unsupported upstream options
- one-off overrides
- gradual migration from existing values files

### `app`

Supported fields:

- `app.host`
- `app.environment`
- `app.loggingLevel`
- `app.isKubernetes`
- `app.useDbAuthentication`

### `database`

Supported fields:

- `database.host`
- `database.port`
- `database.user`
- `database.password`
- `database.name`
- `database.url`

Notes:

- If `database.host` is empty and `nuqPostgres.enabled=true`, the chart uses the built-in `nuq-postgres`
- If `database.url` is empty, `NUQ_DATABASE_URL` is auto-generated from the database fields

### `search`

Supported fields:

- `search.searxngEndpoint`
- `search.searxngEngines`
- `search.searxngCategories`

### `supabase`

Supported fields:

- `supabase.url`
- `supabase.anonToken`
- `supabase.serviceToken`

Notes:

- Supabase-backed DB authentication currently has limited upstream self-host support.
- For self-hosted auth, prefer `apiKeys.testApiKey` (`TEST_API_KEY`).
- These values render `SUPABASE_URL`, `SUPABASE_ANON_TOKEN`, and `SUPABASE_SERVICE_TOKEN`.

### `apiKeys`

Supported fields:

- `apiKeys.openaiApiKey`
- `apiKeys.openaiBaseUrl`
- `apiKeys.bullAuthKey`
- `apiKeys.testApiKey`
- `apiKeys.slackWebhookUrl`
- `apiKeys.llamaParseApiKey`

### `playwright`

Supported fields:

- `playwright.enabled`
- `playwright.url`
- `playwright.proxy.server`
- `playwright.proxy.username`
- `playwright.proxy.password`

If `playwright.url` is empty and `playwright.enabled=true`, the chart points Firecrawl to the built-in `playwright` service automatically.

### `valkey`

Supported fields:

- `valkey.enabled`
- `valkey.url`
- `valkey.rateLimitUrl`

If `valkey.url` or `valkey.rateLimitUrl` is empty and `valkey.enabled=true`, the chart points Firecrawl to the built-in `valkey`.

## Minimal Example

```yaml
app:
  environment: production
  loggingLevel: INFO
  useDbAuthentication: false

search:
  searxngEndpoint: http://lobehub-searxng:8080

apiKeys:
  bullAuthKey: "replace-me"
  testApiKey: "replace-me"

playwright:
  enabled: true

nuqPostgres:
  enabled: true

valkey:
  enabled: true
```

## Existing Secrets Or Env

You can still keep legacy configuration through:

- `env`
- `secrets`
- `extraEnvFrom`

Explicit `env` and `secrets` override the auto-generated defaults.

## DB Auth Caveat

As of March 13, 2026, Firecrawl's official self-hosting docs still state that Supabase-backed DB authentication is not fully supported for self-hosted deployments, even though the related env vars exist.

For self-hosted deployments, use `TEST_API_KEY` via `apiKeys.testApiKey` as the practical default.
