# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Helm Charts repository for deploying self-hosted applications on Kubernetes. Charts are hosted on GitHub Pages and published automatically via GitHub Actions.

## Chart Structure

Each chart follows the standard Helm structure:

```
charts/<chart-name>/
├── Chart.yaml          # Chart metadata (name, description, version, appVersion)
├── values.yaml         # Default configuration values
├── templates/
│   ├── _helpers.tpl    # Template helper functions
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── httproute.yaml  # Gateway API support
│   ├── pvc.yaml
│   ├── serviceaccount.yaml
│   ├── hpa.yaml
│   └── tests/
│       └── test-connection.yaml
└── NOTES.txt           # Post-installation notes for users
```

## Chart Development Standards

### Adding a New Chart

1. Create base structure with `helm create charts/<chart-name>`
2. Edit `Chart.yaml`:
   - Set appropriate `name` and `description`
   - Start `version` at 0.0.1 (follow SemVer)
   - Set `appVersion` to the actual application version
3. Configure `values.yaml` with standard configuration options
4. Write templates using `_helpers.tpl` helper functions
5. Write `NOTES.txt` for post-installation instructions

### Required Configuration Options

All charts must support these standard configurations:

```yaml
replicaCount: 1
image:
  repository: <app>/app
  pullPolicy: IfNotPresent
  tag: ""

service:
  type: ClusterIP
  port: <app-port>

ingress:
  enabled: false
  className: ""
  annotations: {}
  hosts: []
  tls: []

httpRoute:
  enabled: false
  parentRefs: []
  hostnames: []
  rules: []

persistence:
  enabled: false
  size: 1Gi
  storageClass: ""
  accessMode: ReadWriteOnce

resources: {}

autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 100
  targetCPUUtilizationPercentage: 80
```

### Template Helpers

Standard `_helpers.tpl` helpers (replace `<chart-name>` with actual name):

- `<chart-name>.name` - Chart name
- `<chart-name>.fullname` - Full resource name
- `<chart-name>.chart` - Chart information
- `<chart-name>.selectorLabels` - Selector labels
- `<chart-name>.commonLabels` - Common labels
- `<chart-name>.serviceAccountName` - Service account name

## Common Commands

### Testing Charts

```bash
# Template rendering test
helm template my-release charts/<chart-name>

# Dry-run install
helm install my-release charts/<chart-name> --dry-run --debug

# Actual install test
helm install my-release charts/<chart-name>

# Show values
helm show values charts/<chart-name>
```

### Publishing

Charts are published automatically when pushed to `main` branch with changes in `charts/` directory:
1. Update chart files
2. Increment `version` in `Chart.yaml`
3. Commit and push to `main`
4. CI automatically packages and publishes to GitHub Pages

## CI/CD Pipeline

**Trigger:** Push to `main` branch with `charts/**` path changes

**Workflow steps:**
1. Run `helm/chart-releaser-action` to publish charts
2. Prune `index.yaml` (keep only latest version per chart)
3. Cleanup old releases/tags (keep only 2 most recent per chart)

**Storage:** GitHub Pages hosts the Helm repository

## Version Management

- Chart versions follow [SemVer](https://semver.org/)
- Increment `version` in `Chart.yaml` for each chart modification
- `appVersion` should match the actual application version
