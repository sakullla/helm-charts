# Helm Charts Repository - Agent Guide

## Project Overview

This is a **Helm Charts Repository** for Kubernetes applications, hosted on GitHub Pages. The repository contains 39 Helm charts for deploying various applications and services to Kubernetes clusters.

- **Repository**: https://github.com/sakullla/helm-charts.git
- **Charts Repository URL**: https://sakullla.github.io/helm-charts
- **License**: GNU General Public License v3.0 (GPL-3.0)
- **Language**: English (primary), with some Chinese comments in configuration files

## Technology Stack

| Component | Technology |
|-----------|------------|
| Package Manager | Helm 3 |
| Target Platform | Kubernetes |
| CI/CD | GitHub Actions |
| Artifact Hosting | GitHub Pages |
| Configuration Language | YAML |
| Templating | Go templates (Helm) |

## Repository Structure

```
helm-charts/
├── .github/
│   └── workflows/
│       └── release.yml       # GitHub Actions workflow for chart releases
├── charts/                   # All Helm charts (39 charts)
│   ├── adguard-home/
│   ├── affine/
│   ├── ani-rss/
│   ├── astrbot/
│   ├── browserless-chromium/
│   ├── calibre-web-automated/
│   ├── certimate/
│   ├── chartdb/
│   ├── ddns-go/
│   ├── dns-server/
│   ├── firecrawl/
│   ├── frp/
│   ├── headplane/
│   ├── headscale/
│   ├── hedgedoc/
│   ├── hedgedoc-backend/
│   ├── hubproxy/
│   ├── hugo-site/
│   ├── kavita/
│   ├── kirara-agent/
│   ├── koipy/
│   ├── lobehub/
│   ├── logvar/
│   ├── miaospeed/
│   ├── misaka-danmu-server/
│   ├── misub/
│   ├── newapi/
│   ├── next-ai-draw-io/
│   ├── openlist/
│   ├── oplist-api/
│   ├── playwright-service/
│   ├── qbittorrent/
│   ├── saveany-bot/
│   ├── searxng/
│   ├── substore/
│   ├── tabby-web/
│   ├── vaultwarden/
│   ├── xray/
│   └── yamtrack/
├── .idea/                    # IntelliJ IDEA configuration
└── LICENSE                   # GPL-3.0 License
```

## Chart Structure

Each Helm chart follows the standard Helm directory structure:

```
charts/<chart-name>/
├── Chart.yaml                # Chart metadata (name, version, description, dependencies)
├── values.yaml               # Default configuration values
├── .helmignore               # Patterns to ignore when packaging
└── templates/
    ├── _helpers.tpl          # Named templates and helper functions
    ├── deployment.yaml       # Kubernetes Deployment resource
    ├── service.yaml          # Kubernetes Service resource
    ├── serviceaccount.yaml   # Kubernetes ServiceAccount resource
    ├── ingress.yaml          # Kubernetes Ingress resource (optional)
    ├── httproute.yaml        # Gateway API HTTPRoute (optional)
    ├── hpa.yaml              # HorizontalPodAutoscaler (optional)
    ├── pvc.yaml              # PersistentVolumeClaim (optional)
    ├── configmap.yaml        # ConfigMap for configuration (optional)
    ├── secret.yaml           # Secret for sensitive data (optional)
    └── tests/
        └── test-connection.yaml  # Helm test hooks
```

### Standard Template Files

- **deployment.yaml**: Main application deployment with configurable replicas, resources, probes
- **service.yaml**: Exposes the application within the cluster
- **serviceaccount.yaml**: RBAC service account configuration
- **ingress.yaml**: Traditional Kubernetes Ingress for external access
- **httproute.yaml**: Gateway API HTTPRoute (modern alternative to Ingress)
- **hpa.yaml**: Horizontal Pod Autoscaler for automatic scaling
- **pvc.yaml**: Persistent volume claims for data persistence
- **configmap.yaml**: Non-sensitive configuration data
- **secret.yaml**: Sensitive data like passwords and API keys

### Common Values Pattern

All charts follow a consistent `values.yaml` structure:

```yaml
# Core settings
replicaCount: 1
image:
  repository: <docker-image>
  pullPolicy: IfNotPresent
  tag: ""  # Defaults to chart appVersion

# Naming overrides
nameOverride: ""
fullnameOverride: ""

# Service account
serviceAccount:
  create: true
  automount: true
  annotations: {}
  name: ""

# Pod settings
podAnnotations: {}
podLabels: {}
podSecurityContext: {}
securityContext: {}

# Networking
service:
  type: ClusterIP
  port: <port>

ingress:
  enabled: false
  className: ""
  annotations: {}
  hosts: []
  tls: []

httpRoute:
  enabled: false
  # ... Gateway API configuration

# Resource management
resources: {}
autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 100
  targetCPUUtilizationPercentage: 80

# Persistence
persistence:
  enabled: false
  accessMode: ReadWriteOnce
  size: 1Gi
  storageClass: ""

# Scheduling
nodeSelector: {}
tolerations: []
affinity: {}

# Probes (varies by chart)
livenessProbe: {}
readinessProbe: {}
startupProbe: {}
```

## Build and Release Process

### Automated Release Workflow

The repository uses GitHub Actions (`.github/workflows/release.yml`) that triggers on pushes to `main` branch when changes are made under `charts/**`:

1. **Chart Packaging**: Uses `helm/chart-releaser-action@v1.5.0` to package and release charts
2. **Index Management**: Automatically updates `index.yaml` on the `gh-pages` branch
3. **Version Pruning**: Keeps only the latest version of each chart in the index
4. **Release Cleanup**: Retains only the 2 most recent releases per chart

### Version Management

- **Chart Version**: Incremented manually in `Chart.yaml` when chart templates change
- **App Version**: Updated when the underlying application version changes
- Follows **Semantic Versioning** (https://semver.org/)

### Dependencies

Some charts have dependencies (e.g., `firecrawl` depends on `playwright-service`):

```yaml
dependencies:
  - name: playwright-service
    version: 0.1.1
    repository: https://sakullla.github.io/helm-charts
    condition: playwright-service.enabled
```

## Development Guidelines

### Creating a New Chart

1. Use `helm create <chart-name>` or copy an existing chart as template
2. Update `Chart.yaml` with:
   - `apiVersion: v2`
   - `type: application`
   - Appropriate `version` and `appVersion`
   - `description` describing the application
3. Configure `values.yaml` with sensible defaults
4. Update templates to use the helper functions from `_helpers.tpl`
5. Add test hooks in `templates/tests/`
6. Ensure `.helmignore` excludes unnecessary files

### Naming Conventions

- Chart names: lowercase with hyphens (e.g., `adguard-home`, `calibre-web-automated`)
- Template helpers: `<chart-name>.<function-name>` (e.g., `adguard-home.fullname`)
- Resource names: Use `{{ include "<chart-name>.fullname" . }}` pattern
- Labels: Follow Helm 3 standard labels (see `_helpers.tpl`)

### Template Best Practices

1. **Always use helper templates** for naming:
   ```yaml
   name: {{ include "chart-name.fullname" . }}
   labels:
     {{- include "chart-name.labels" . | nindent 4 }}
   ```

2. **Conditional rendering** using `with` and `if`:
   ```yaml
   {{- with .Values.podAnnotations }}
   annotations:
     {{- toYaml . | nindent 8 }}
   {{- end }}
   ```

3. **Quote values** that might be interpreted as non-strings:
   ```yaml
   app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
   ```

### Testing Charts

Each chart includes a test hook in `templates/tests/test-connection.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: "{{ include "chart-name.fullname" . }}-test-connection"
  annotations:
    "helm.sh/hook": test
spec:
  containers:
    - name: wget
      image: busybox
      command: ['wget']
      args: ['{{ include "chart-name.fullname" . }}:{{ .Values.service.port }}']
  restartPolicy: Never
```

Run tests with: `helm test <release-name>`

## CI/CD Commands

### Local Chart Validation

```bash
# Lint a chart
helm lint charts/<chart-name>

# Validate templates
helm template <release-name> charts/<chart-name>

# Package a chart
helm package charts/<chart-name>

# Install locally for testing
helm install <release-name> charts/<chart-name> --dry-run

# Run chart tests
helm test <release-name>
```

### Dependency Management

```bash
# Update chart dependencies
helm dependency update charts/<chart-name>

# Build dependency charts
helm dependency build charts/<chart-name>
```

## Special Chart Configurations

### Multi-Component Charts

Some charts deploy multiple components:

- **frp**: Deploys both `frps` (server) and `frpc` (client) with conditional enabling
- **firecrawl**: Deploys API, worker, and nuq-postgres components

### Gateway API Support

Modern charts include `httproute.yaml` for Gateway API (alternative to Ingress):

```yaml
httpRoute:
  enabled: false
  parentRefs:
    - name: gateway
      sectionName: http
  hostnames:
    - chart-example.local
```

## Security Considerations

1. **Default Security Contexts**: Charts provide commented security context examples
2. **Service Accounts**: Created by default with minimal permissions
3. **Secrets**: Support for managing sensitive data via `secrets:` in values.yaml
4. **Network Policies**: Not included by default; cluster-level configuration recommended

## Common Issues and Solutions

### Release Fails
- Ensure `version` in `Chart.yaml` is incremented for changes
- Check that `appVersion` matches the container image tag if pinned

### Template Errors
- Validate YAML indentation (2 spaces standard)
- Check that all `{{` and `}}` are properly balanced
- Verify helper templates match chart name

### Index Not Updating
- The workflow only triggers on changes to `charts/**`
- Check GitHub Actions logs for errors in the release workflow

## References

- [Helm Documentation](https://helm.sh/docs/)
- [Helm Chart Best Practices](https://helm.sh/docs/chart_best_practices/)
- [Kubernetes Gateway API](https://gateway-api.sigs.k8s.io/)
- [Semantic Versioning](https://semver.org/)
