# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Helm charts repository hosting 40+ production-ready charts for self-hosted Kubernetes applications. Charts are distributed via GitHub Pages at `https://sakullla.github.io/helm-charts` and automatically published through GitHub Actions.

## Build & Development Commands

### Local Chart Validation
```bash
# Render templates to YAML (quick syntax check)
helm template my-release charts/<chart-name>

# Simulate install with validation (catches most errors)
helm install my-release charts/<chart-name> --dry-run --debug

# Test actual installation on local cluster
helm install my-release charts/<chart-name>

# View default values
helm show values charts/<chart-name>
```

### Repository Operations
```bash
# Add the published repository
helm repo add sakullla https://sakullla.github.io/helm-charts
helm repo update

# Search available charts
helm search repo sakullla
```

## Chart Architecture

### Standard Structure
Every chart follows this template structure:
```
charts/<chart-name>/
├── Chart.yaml              # Chart metadata, version, appVersion, dependencies
├── values.yaml             # Default configuration with inline documentation
├── templates/
│   ├── _helpers.tpl        # Template helpers (names, labels, selectors)
│   ├── deployment.yaml     # Main workload
│   ├── service.yaml        # Service definition
│   ├── ingress.yaml        # Optional Ingress (enabled via values)
│   ├── httproute.yaml      # Optional Gateway API HTTPRoute
│   ├── pvc.yaml            # Optional PersistentVolumeClaim
│   ├── hpa.yaml            # Optional HorizontalPodAutoscaler
│   ├── serviceaccount.yaml # ServiceAccount
│   └── NOTES.txt           # Post-install instructions
└── tests/                  # Helm test pods (when applicable)
```

### Common Template Patterns
All charts use `_helpers.tpl` for:
- `<chart-name>.name`: Chart name (from `.Chart.Name` or `nameOverride`)
- `<chart-name>.fullname`: Full resource name (handles release name collision)
- `<chart-name>.chart`: Chart name+version for `helm.sh/chart` label
- `<chart-name>.labels`: Standard labels (chart, version, managed-by)
- `<chart-name>.selectorLabels`: Selector labels (name, instance)
- `<chart-name>.serviceAccountName`: ServiceAccount name resolution

### Network Exposure Options
Charts support multiple ingress methods (mutually compatible):
1. **Ingress** (nginx/traefik) - set `ingress.enabled: true`
2. **Gateway API HTTPRoute** - set `httpRoute.enabled: true`
3. **LoadBalancer/NodePort** - via `service.type`
4. **Port-forward** - for local testing only

### Standard Values Schema
All charts implement these standard configuration blocks:
```yaml
replicaCount: 1
image:
  repository: <app-image>
  pullPolicy: IfNotPresent
  tag: ""  # defaults to Chart.appVersion
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
  accessMode: ReadWriteOnce
  size: 1Gi
  storageClass: ""
resources: {}
autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 100
nodeSelector: {}
tolerations: []
affinity: {}
```

### Chart Dependencies
Some charts include Helm dependencies (e.g., `claude-relay-service` includes `valkey`):
- Dependencies declared in `Chart.yaml` under `dependencies`
- Sub-chart values configured under the dependency alias in `values.yaml`
- Use `helm dependency update charts/<chart-name>` to fetch dependencies locally

## Version Management

### SemVer for Chart Versions
- **MAJOR**: Breaking changes to values schema or behavior
- **MINOR**: New features (e.g., adding HTTPRoute support)
- **PATCH**: Bug fixes, documentation, non-breaking updates

### AppVersion vs Chart Version
- `version` in `Chart.yaml`: The chart itself (increment on ANY change)
- `appVersion`: The application container image version (tracks upstream)
- `image.tag` in `values.yaml`: If empty, defaults to `appVersion`

**CRITICAL**: Always bump `Chart.yaml` `version` when modifying any chart files. CI will only publish charts with changed versions.

## CI/CD Pipeline

### Release Workflow (`.github/workflows/release.yml`)
Triggered on push to `main` when `charts/**` changes:

1. **Chart Release**: Uses `helm/chart-releaser-action` to:
   - Package changed charts
   - Create GitHub releases with tags (`<chart-name>-<version>`)
   - Update `index.yaml` on `gh-pages` branch

2. **Index Pruning**: Python script keeps only the latest version per chart in `index.yaml` to prevent bloat

3. **Release Cleanup**: Deletes old GitHub releases/tags, keeping only last 2 per chart

### Key CI Details
- Only charts with modified `Chart.yaml` versions are released
- Workflow uses `secrets.GITHUB_TOKEN` for authentication
- Commits to `gh-pages` use `[skip ci]` to prevent loops
- Cleanup targets only charts modified in the current push

## Chart Development Guidelines

### When Creating/Modifying Charts
1. Follow the standard template structure shown above
2. Use helpers from `_helpers.tpl` for all names/labels
3. Document all `values.yaml` options with inline comments
4. Implement both `ingress` and `httpRoute` support (conditional)
5. Add `NOTES.txt` with post-install access instructions
6. Test with `--dry-run --debug` before committing

### Values Documentation Style
```yaml
# Brief description of the setting
# Additional context if needed (default behavior, constraints)
settingName: defaultValue
```

### Probe Configuration
Charts use startup/liveness/readiness probes:
- **startupProbe**: High `failureThreshold` * `periodSeconds` for slow startup
- **livenessProbe**: Restarts unhealthy pods
- **readinessProbe**: Controls service endpoint membership

Most charts use `tcpSocket` probes on the main service port. HTTP-based applications may use `httpGet` instead.

## Special Notes

### Chinese Documentation
The `README.md` is in Chinese (repository target audience). Chart descriptions in `Chart.yaml` may be English or Chinese.

### Available Skills
This repository includes two Claude Code skills:
- `git-workflow`: Git operations (branching, rebasing, commits)
- `helm-chart-builder`: Create/refactor charts following repository patterns

Use `/git-workflow` or `/helm-chart-builder` to invoke these skills.

### Commit Message Format
Follow semantic commit style:
- `feat(chart-name): add new feature`
- `fix(chart-name): resolve issue`
- `chore: update CI configuration`

### Do Not Create
- Additional README files per chart (use `NOTES.txt` for usage)
- Generic `.helmignore` files (not needed in this repository)
- Chart documentation in separate docs folders (inline `values.yaml` comments suffice)
