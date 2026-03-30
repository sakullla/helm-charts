# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

Run from the repository root:

```bash
helm lint charts/<chart-name>
helm template my-release charts/<chart-name> --debug
helm install my-release charts/<chart-name> --dry-run --debug -n <ns> --create-namespace
helm dependency update charts/<chart-name>   # charts with Chart.yaml dependencies
helm package charts/<chart-name>
helm test <release>                          # when templates/tests/test-connection.yaml exists
```

## Repository Structure

Helm chart monorepo. Each chart lives in `charts/<chart-name>/` with its own independent versioning. The `gh-pages` branch hosts the Helm repository index (`index.yaml`). CI (`.github/workflows/release.yml`) runs `chart-releaser` on every push to `main` that touches `charts/**`, then prunes `index.yaml` to keep only the latest version per chart and cleans up GitHub releases to keep the last two per chart.

## Chart Conventions

### Standard template files

Every chart uses this set:

| File | Purpose |
|------|---------|
| `_helpers.tpl` | Naming/label helpers prefixed with chart name (`chartname.fullname`, `chartname.labels`, etc.) |
| `deployment.yaml` | Main workload; must include checksum annotations |
| `service.yaml` | ClusterIP service |
| `serviceaccount.yaml` | ServiceAccount with `automount` |
| `configmap.yaml` | Renders `.Values.env` as environment variables |
| `secret.yaml` | Base64-encodes `.Values.secrets` |
| `ingress.yaml` | Optional; toggled by `ingress.enabled` |
| `httproute.yaml` | Optional Gateway API route; toggled by `httpRoute.enabled` |
| `hpa.yaml` | Optional; toggled by `autoscaling.enabled` |
| `pvc.yaml` | Optional; toggled by `persistence.enabled` |
| `NOTES.txt` | Post-install instructions |
| `tests/test-connection.yaml` | Optional Helm test hook |

### Deployment must-haves

Always include checksum annotations so config changes trigger rollouts:

```yaml
annotations:
  checksum/config: {{ include (print $.Template.BasePath "/configmap.yaml") . | sha256sum }}
  checksum/secret: {{ include (print $.Template.BasePath "/secret.yaml") . | sha256sum }}
```

Use `strategy: type: Recreate` whenever `persistence.enabled` or `.Values.volumes` is set (avoids ReadWriteOnce PVC conflicts during rolling updates).

Container spec must include:
- Optional `.Values.command` and `.Values.args` overrides
- `envFrom` for both the ConfigMap and the Secret
- `startupProbe`, `livenessProbe`, `readinessProbe`

Prefer `startupProbe.tcpSocket` for fast startup detection when no dedicated startup HTTP endpoint exists.

### values.yaml layout

Group values by functional section in this order: `replicaCount`, `image`, `imagePullSecrets`, `nameOverride`/`fullnameOverride`, `command`/`args`, `serviceAccount`, `podAnnotations`, `podLabels`, `podSecurityContext`, `securityContext`, `service`, `ingress`, `httpRoute`, `startupProbe`/`livenessProbe`/`readinessProbe`, `resources`, `autoscaling`, `persistence`, `volumes`/`volumeMounts`, `nodeSelector`, `tolerations`, `affinity`, then app-specific structured sections (e.g. `app`, `database`, `search`, `integrations`), then `env` (ConfigMap) and `secrets` (Secret).

The `assets/values-example.yaml` in the `helm-chart-builder` skill is the canonical template.

### HTTPRoute backendRefs

Always include `group: ''` and `kind: Service` alongside `name`, `port`, and `weight`.

### Multi-component charts

Charts that bundle multiple workloads (e.g. `firecrawl` with api/worker/postgres/valkey) use a single `values.yaml` with structured sub-sections per component, and auto-wire internal service URLs/credentials using `dependencyAutoConfig.enabled`. User-provided `.Values.env` and `.Values.secrets` are merged last and override any generated defaults.

## Creating or Modifying Charts

Use the `/helm-chart-builder` skill — it contains the full workflow, template library (`assets/templates/`), values skeleton, and reference guides.

When modifying an existing chart, always bump `Chart.yaml` `version`. Update `appVersion` when the upstream image version changes.

## Commit Format

Follow Conventional Commits with chart scope:

```
feat(chart-name): add initial chart
fix(chart-name): correct probe path
chore: bump GitHub Actions versions
```
