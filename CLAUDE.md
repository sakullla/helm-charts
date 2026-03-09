# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Multi-chart Helm repository hosting 39 production-ready charts for self-hosted applications. Each chart in `charts/<chart-name>/` is an independent deployment unit with its own versioning. Charts are automatically packaged and published to GitHub Pages (`https://sakullla.github.io/helm-charts`) when changes to `charts/**` are pushed to `main`.

## Development Commands

### Chart Validation
```bash
# Lint chart structure and templates
helm lint charts/<chart-name>

# Render templates locally
helm template <release-name> charts/<chart-name> --debug

# Simulate installation
helm install <release-name> charts/<chart-name> --dry-run --debug -n <namespace> --create-namespace

# Update dependencies (for charts like automem, lobehub, headplane)
helm dependency update charts/<chart-name>

# Package chart
helm package charts/<chart-name>
```

Always run these validation commands before proposing changes. Test both enabled and disabled states for optional features (ingress, httpRoute, persistence, HPA).

## Chart Architecture Patterns

### Standard Chart Structure
```
charts/<chart-name>/
├── Chart.yaml              # Metadata, version (SemVer), appVersion
├── values.yaml             # Default configuration
├── README.md               # Chart-specific documentation
└── templates/
    ├── _helpers.tpl        # Chart-prefixed helper functions
    ├── deployment.yaml     # Main workload
    ├── service.yaml        # Service definition
    ├── serviceaccount.yaml # Service account
    ├── configmap.yaml      # Non-sensitive config (from .Values.env)
    ├── secret.yaml         # Sensitive data (from .Values.secrets)
    ├── ingress.yaml        # Traditional Ingress (optional)
    ├── httproute.yaml      # Gateway API HTTPRoute (optional)
    ├── pvc.yaml            # Persistent storage (optional)
    ├── hpa.yaml            # Horizontal Pod Autoscaler (optional)
    ├── NOTES.txt           # Post-install instructions
    └── tests/
        └── test-connection.yaml
```

### Configuration Management Pattern

All charts follow a two-resource configuration pattern:

1. **ConfigMap** (`templates/configmap.yaml`): Created from `.Values.env` for non-sensitive variables
2. **Secret** (`templates/secret.yaml`): Created from `.Values.secrets` for sensitive data

Both are mounted via `envFrom` in the Deployment container spec. This pattern enables:
- Clear separation of sensitive vs non-sensitive config
- Automatic pod rollout on config changes (via checksum annotations)
- Consistent configuration interface across all charts

### Deployment Conventions

**Checksum Annotations** (critical for config-driven rollouts):
```yaml
template:
  metadata:
    annotations:
      checksum/config: {{ include (print $.Template.BasePath "/configmap.yaml") . | sha256sum }}
      checksum/secret: {{ include (print $.Template.BasePath "/secret.yaml") . | sha256sum }}
```

**Update Strategy**:
- Use `strategy.type: Recreate` when `persistence.enabled` or `.Values.volumes` is set
- This avoids ReadWriteOnce PVC mount conflicts during rolling updates

**Container Overrides**:
- Support optional `.Values.command` and `.Values.args` for startup customization

**Health Probes** (all three required):
- `startupProbe`: Prefer `tcpSocket` on http port for fast startup detection
- `livenessProbe`: Typically `httpGet` on `/health` or `/alive` endpoint
- `readinessProbe`: Typically `httpGet` on `/ready` or `/alive` endpoint

### Network Access

Charts support two mutually exclusive ingress methods:

**Ingress** (traditional):
```yaml
ingress:
  enabled: false
  className: ""
  hosts:
    - host: chart-example.local
      paths:
        - path: /
          pathType: ImplementationSpecific
```

**HTTPRoute** (Gateway API):
```yaml
httpRoute:
  enabled: false
  parentRefs:
    - name: gateway
      sectionName: http
  hostnames:
    - chart-example.local
```

In `httproute.yaml` backendRefs, always include `group: ''` and `kind: Service` alongside `name`, `port`, and `weight`.

### Multi-Component Charts

Some charts model multi-service stacks and require extra attention:

- **automem**: Depends on `falkordb`, `qdrant`, and `automem-graph-viewer` via `dependencies` in Chart.yaml
- **firecrawl**: API, workers, Playwright, optional Nuq Postgres resources in a single chart
- **cognee**: App + Postgres + Neo4j + ChromaDB manifests

When modifying these charts, verify resource names, services, and optional feature toggles remain compatible.

## Naming and Style Conventions

### Naming
- Chart names: lowercase kebab-case (e.g., `adguard-home`, `nginx-stream`)
- Template filenames: lowercase kebab-case (e.g., `deployment.yaml`, `httproute.yaml`)
- Value keys: camelCase (e.g., `replicaCount`, `imagePullSecrets`)
- Helper functions: Chart-prefixed (e.g., `{{ include "vaultwarden.fullname" . }}`)
- Never hardcode resource names; always use helpers

### YAML Style
- 2-space indentation
- Consistent key ordering in values.yaml: image, service, ingress/httpRoute, persistence, resources, env, secrets
- Document non-obvious options with inline comments

## Using the helm-chart-builder Skill

When creating or refactoring charts, use the `helm-chart-builder` skill to enforce repository conventions automatically. The skill:
- Generates charts with ConfigMap/Secret + checksum rollout pattern
- Includes startup/liveness/readiness probes
- Supports both Ingress and HTTPRoute
- Applies standard Helm validation

Reference materials in `.claude/skills/helm-chart-builder/`:
- `assets/templates/`: Template library for all standard resources
- `assets/values-example.yaml`: Default values skeleton
- `assets/README-example.md`: Chart README template
- `references/configuration-guide.md`: values.yaml organization guide
- `references/probes-guide.md`: Probe tuning reference

## Version Management

Follow Semantic Versioning for chart versions in `Chart.yaml`:
- **MAJOR (x.0.0)**: Breaking changes to values or behavior
- **MINOR (0.x.0)**: New features, backward-compatible
- **PATCH (0.0.x)**: Bug fixes, no new features

**Critical**: Always bump `version` in Chart.yaml when modifying a chart. Update `appVersion` when upstream application version changes.

## Commit and PR Conventions

### Commit Format
Use Conventional Commits:
```
<type>(<scope>): <subject>

<body>

<footer>
```

Types: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`
Scope: Chart directory name for chart-specific changes

Examples:
```bash
feat(vaultwarden): add OAuth2 authentication support
fix(lobehub): correct persistence mount path
docs: update installation guide
chore(adguard-home): bump version to 0.2.0
```

### Pull Request Requirements
- PR title follows commit message format
- Include: changed chart names, validation commands executed, breaking-value notes
- For breaking changes, provide migration notes in PR description

## CI/CD Workflow

`.github/workflows/release.yml` automatically:
1. Detects changes in `charts/**`
2. Packages modified charts
3. Publishes to `gh-pages` branch
4. Updates Helm repository index
5. Creates GitHub Release
6. Cleans up old artifacts

Charts must pass validation and have updated versions to be released.

## Security Practices

- Never commit real secrets in `values.yaml` - use placeholders like `""` or `"changeme"`
- Pass sensitive values via `--set`, external secrets operators, or sealed-secret workflows
- Prefer non-root `securityContext` where application supports it
- Set explicit resource requests/limits to prevent resource exhaustion

## Repository Documentation

- `README.md`: User-facing documentation, installation examples (Chinese)
- `CONTRIBUTING.md`: Contributor guide, chart development best practices (Chinese)
- `PROJECT_STRUCTURE.md`: Repository structure and workflow explanation (Chinese)
- `AGENTS.md`: Agent-specific development rules and validation workflow (English)
