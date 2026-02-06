---
name: helm-chart-builder
description: Build production-ready Helm charts for Kubernetes applications. Use when creating new charts, refactoring existing charts, adding features like Ingress/Gateway API/dependencies, or following Helm best practices.
---

# Helm Chart Builder

Build production-ready Helm charts with standard patterns for:
- Multi-tier web applications
- API services with caching (Redis/Valkey)
- Stateful services with persistence

## Quick Start

### Create New Chart

```bash
helm create my-chart
cd my-chart

# Remove example files
rm -rf templates/tests/* templates/NOTES.txt templates/ingress.yaml
rm -rf templates/hpa.yaml templates/serviceaccount.yaml
```

### Apply Standard Structure

Copy templates from [assets/templates/](assets/templates/):

| File | Purpose |
|------|---------|
| `_helpers.tpl` | Standard helper functions |
| `deployment.yaml` | Full-featured deployment with probes |
| `service.yaml` | ClusterIP/NodePort/LoadBalancer support |
| `serviceaccount.yaml` | Service account for pod identity |
| `configmap.yaml` | Non-sensitive environment variables |
| `secret.yaml` | Sensitive configuration |
| `ingress.yaml` | Ingress with TLS support |
| `httproute.yaml` | Gateway API HTTPRoute support |
| `pvc.yaml` | Persistent volume claim for storage |
| `hpa.yaml` | Horizontal pod autoscaling |
| `NOTES.txt` | Post-install instructions |

## Chart Structure

```
my-chart/
├── Chart.yaml           # Metadata + dependencies
├── values.yaml          # Default configuration
├── .helmignore          # Build exclusions
└── templates/
    ├── _helpers.tpl     # Template helpers
    ├── deployment.yaml  # Main workload
    ├── service.yaml     # Service exposure
    ├── serviceaccount.yaml  # Service account (optional)
    ├── configmap.yaml   # Env vars (non-sensitive)
    ├── secret.yaml      # Env vars (sensitive)
    ├── ingress.yaml     # Ingress (optional)
    ├── httproute.yaml   # Gateway API (optional)
    ├── pvc.yaml         # Persistence (optional)
    ├── hpa.yaml         # Autoscaling (optional)
    └── NOTES.txt        # User instructions
```

## Core Templates

### 1. Deployment Template

Key features to include:
- Labels and selectors using helpers
- ConfigMap/Secret checksum for rollout triggers
- Three probe types: startup, liveness, readiness
- Resource limits and requests
- Security contexts
- Volume mounts for persistence

See [assets/templates/deployment.yaml](assets/templates/deployment.yaml)

### 2. Service Template

Support three types:
- `ClusterIP` (default)
- `NodePort`
- `LoadBalancer`

### 3. Config Management

Separate sensitive and non-sensitive:

```yaml
# values.yaml
env:      # -> ConfigMap (non-sensitive)
  LOG_LEVEL: info
  PORT: 3000

secrets:  # -> Secret (base64 encoded)
  API_KEY: ""
  DATABASE_URL: ""
```

Reference deployment to inject:

```yaml
envFrom:
  - configMapRef:
      name: {{ include "chart.fullname" . }}-config
  - secretRef:
      name: {{ include "chart.fullname" . }}-secret
```

### 4. Ingress Support

Standard Ingress + Gateway API HTTPRoute:

```yaml
# values.yaml
ingress:
  enabled: false
  className: nginx
  hosts: []
  tls: []

httpRoute:
  enabled: false
  parentRefs: []
  hostnames: []
```

## Best Practices

### Values.yaml Organization

```yaml
# 1. Base configuration
replicaCount: 1
image:
  repository: app
  tag: ""
  pullPolicy: IfNotPresent

# 2. Service configuration
service:
  type: ClusterIP
  port: 80

# 3. Networking
ingress:
  enabled: false
  # ...

httpRoute:
  enabled: false
  # ...

# 4. Storage
persistence:
  enabled: false
  size: 1Gi
  storageClass: ""

# 5. Resources and scaling
resources: {}
autoscaling:
  enabled: false
  # ...

# 6. Application-specific
env: {}
secrets: {}
```

### Naming Conventions

Use standard helpers in `_helpers.tpl`:

```yaml
{{- define "chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "chart.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "chart.labels" -}}
helm.sh/chart: {{ include "chart.chart" . }}
{{ include "chart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
```

### Dependencies

Add to `Chart.yaml`:

```yaml
dependencies:
  - name: valkey
    version: ~2.0.0
    repository: https://valkey-io.github.io/valkey-helm
    condition: valkey.enabled
```

## Testing

```bash
# Template validation
helm template my-release ./my-chart

# Dry run
helm install --dry-run --debug my-release ./my-chart

# Lint
helm lint ./my-chart
```

## Common Patterns

### Pattern: Auto-detect Internal Dependency Host

```yaml
# deployment.yaml
env:
  {{- if .Values.valkey.enabled }}
  - name: REDIS_HOST
    value: "{{ .Release.Name }}-valkey"
  {{- end }}
```

### Pattern: Conditional Resource Creation

```yaml
# Only create if enabled AND not existing
{{- if and .Values.persistence.enabled (not .Values.persistence.existingClaim) }}
apiVersion: v1
kind: PersistentVolumeClaim
...
{{- end }}
```

### Pattern: Rollout Trigger on Config Change

```yaml
annotations:
  checksum/config: {{ include (print $.Template.BasePath "/configmap.yaml") . | sha256sum }}
  checksum/secrets: {{ include (print $.Template.BasePath "/secret.yaml") . | sha256sum }}
```

## References

- [Template Library](assets/templates/) - Production-ready templates
- [Configuration Guide](references/configuration-guide.md) - Complete values.yaml reference
- [Probes Guide](references/probes-guide.md) - Health check best practices
