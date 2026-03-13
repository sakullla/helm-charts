# lobehub

Helm chart for deploying LobeHub on Kubernetes.

This chart is optimized for fast self-hosting with fewer values to maintain:

- Built-in `ParadeDB` for database mode
- Built-in `SearXNG` for search
- Structured values for common LobeHub settings
- Backward-compatible with raw `env` and `secrets`

Current chart metadata:

- Chart version: `0.0.26`
- App version: `2.1.39`

## What This Chart Deploys

By default, this chart deploys:

- `lobehub`
- `paradedb`
- `searxng`

Built-in `searxng` ships with a default `config` block, so it works without manually providing `settings.yml` or `limiter.toml`.

Default auto wiring:

- `DATABASE_URL` points to the embedded `ParadeDB`
- `SEARXNG_URL` points to the in-chart `SearXNG`
- `SEARCH_PROVIDERS` defaults to `searxng`
- `CRAWLER_IMPLS` defaults to `naive`

You can still override any of these through structured values, `env`, or `secrets`.

## Quick Start

Minimal install:

```bash
helm dependency update charts/lobehub
helm install lobehub charts/lobehub -n lobehub --create-namespace
```

Recommended starting point:

```bash
helm install lobehub charts/lobehub \
  -n lobehub \
  --create-namespace \
  -f charts/lobehub/values-quickstart.example.yaml
```

Validation:

```bash
helm lint charts/lobehub
helm template lobehub charts/lobehub --debug
helm install lobehub charts/lobehub --dry-run --debug -n lobehub --create-namespace
```

## Recommended Values Style

Use the structured sections first:

- `app`
- `database`
- `auth`
- `storage`
- `llm`
- `search`

Keep `env` and `secrets` for:

- unsupported upstream env vars
- one-off overrides
- gradual migration from older values files

## Minimal Example

```yaml
image:
  repository: lobehub/lobehub
  tag: "2.1.40"

httpRoute:
  enabled: true
  parentRefs:
    - group: gateway.networking.k8s.io
      kind: Gateway
      name: traefik-gateway
      namespace: kube-system
  hostnames:
    - lobechat.example.com
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /

auth:
  secret: "replace-me"
  keyVaultsSecret: "replace-me"
  ssoProviders: github
  env:
    AUTH_GITHUB_ID: "replace-me"
  secrets:
    AUTH_GITHUB_SECRET: "replace-me"

llm:
  openai:
    proxyUrl: http://newapi:3000/v1
    apiKey: "replace-me"

storage:
  s3:
    enabled: true
    bucket: lobechat
    endpoint: https://s3.example.com
    publicDomain: https://cdn.example.com
    accessKeyId: "replace-me"
    secretAccessKey: "replace-me"

search:
  providers: searxng
  crawlerImpls: naive

paradedb:
  enabled: true

searxng:
  enabled: true
```

## Structured Values

### `app`

- `app.url`

If empty, `APP_URL` is auto-derived from `httpRoute.hostnames` or `ingress.hosts`.

### `database`

- `database.url`

If empty and `paradedb.enabled=true`, the chart auto-generates `DATABASE_URL`.

### `auth`

- `auth.secret`
- `auth.keyVaultsSecret`
- `auth.ssoProviders`
- `auth.allowedEmails`
- `auth.emailVerification`
- `auth.disableEmailPassword`
- `auth.oidc.enabled`
- `auth.oidc.jwksKey`
- `auth.env`
- `auth.secrets`

### `storage`

- `storage.s3.enabled`
- `storage.s3.bucket`
- `storage.s3.endpoint`
- `storage.s3.publicDomain`
- `storage.s3.enablePathStyle`
- `storage.s3.setAcl`
- `storage.s3.accessKeyId`
- `storage.s3.secretAccessKey`

### `llm`

- `llm.openai.apiKey`
- `llm.openai.proxyUrl`
- `llm.vision.imageUseBase64`

### `search`

- `search.providers`
- `search.crawlerImpls`
- `search.searxngUrl`

Defaults:

- `SEARCH_PROVIDERS=searxng`
- `CRAWLER_IMPLS=naive`

## Built-in Services

### ParadeDB

- `paradedb.*`
- Built-in startup detection defaults to `paradedb.startupProbe.tcpSocket.port=postgres`.
- `paradedb.livenessProbe` / `paradedb.readinessProbe` are overridable in values.

### SearXNG

- `searxng.*`
- `search.searxngUrl`

## Using Existing Secrets

Use `extraEnvFrom` if secrets are managed externally:

```yaml
extraEnvFrom:
  - secretRef:
      name: lobehub-extra
```

## Backward Compatibility

This chart still supports:

- `env`
- `secrets`

Explicit `env` / `secrets` values override auto-generated defaults.

## Migration Notes

1. Move common settings into structured sections.
2. Keep provider-specific leftovers in `auth.env`, `auth.secrets`, `env`, or `secrets`.
3. Use `extraEnvFrom` for externally managed secrets.
4. Disable built-in `paradedb` or `searxng` only when external equivalents already exist.
