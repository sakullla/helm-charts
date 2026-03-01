---
name: helm-chart-builder
description: Create or refactor Helm charts in this repository using the house style (ConfigMap/Secret + checksum rollout, startup/liveness/readiness probes, ingress + HTTPRoute, and standard Helm validation). Use when asked to build a new chart, rebuild an existing chart, or align chart files with charts/* conventions.
---

# Helm Chart Builder

Use this skill to produce repository-consistent charts quickly and safely.

## Follow This Workflow

1. Pick a baseline chart from `charts/*` with a similar app shape.
2. Create the chart with `helm create charts/<chart-name>`.
3. Update `Chart.yaml`:
   - Set `description` to the app purpose.
   - Add a `keywords` list with at least 3 chart-relevant keywords.
   - Set `version: 0.0.1` for a new chart.
   - Set `appVersion` to the app image tag you want as default.
4. Build `values.yaml` from `assets/values-example.yaml`:
   - Set image repository and service port.
   - Keep `command`/`args` as optional overrides.
   - Keep `env` (ConfigMap) and `secrets` (Secret).
   - Keep `startupProbe`, `livenessProbe`, `readinessProbe`.
5. Apply templates from `assets/templates/`:
   - Required: `_helpers.tpl`, `deployment.yaml`, `service.yaml`, `serviceaccount.yaml`, `configmap.yaml`, `secret.yaml`.
   - Optional: `ingress.yaml`, `httproute.yaml`, `hpa.yaml`, `pvc.yaml`, `NOTES.txt`.
6. Create `README.md` in `charts/<chart-name>/` from `assets/README-example.md`:
   - Include: Overview, Prerequisites, Installation, Configuration, Key Values, Validation.
   - Document required secrets/env values and one runnable example values snippet.
   - Keep defaults in README consistent with `values.yaml`.
7. Validate with Helm before finishing.

## Keep These Repository Conventions

- Always route app configuration through:
  - `templates/configmap.yaml` from `.Values.env`
  - `templates/secret.yaml` from `.Values.secrets`
- In Deployment annotations, always include:
  - `checksum/config` from `configmap.yaml`
  - `checksum/secret` from `secret.yaml`
- In Deployment `spec`, add `strategy: type: Recreate` whenever `persistence.enabled` or `.Values.volumes` is set, to avoid ReadWriteOnce PVC mount conflicts during rolling updates.
- In Deployment container spec, include:
  - optional `.Values.command` and `.Values.args`
  - `envFrom` for both ConfigMap and Secret
  - `startupProbe`, `livenessProbe`, `readinessProbe`
- Prefer `startupProbe.tcpSocket` for fast startup detection when no dedicated startup endpoint is needed.
- In `httproute.yaml` `backendRefs`, always include `group: ''` and `kind: Service` alongside `name`, `port`, and `weight`.
- Keep helper-based naming/labels; do not hardcode resource names.
- Keep YAML indentation as two spaces.
- Each chart should include a chart-local `README.md`.

## Validate Every Change

Run:

```bash
helm template my-release charts/<chart-name>
helm lint charts/<chart-name>
helm install my-release charts/<chart-name> --dry-run --debug
```

If modifying an existing chart, bump `Chart.yaml` `version` in the same change.

## Reuse Skill Assets

- Template library: `assets/templates/`
- Default values skeleton: `assets/values-example.yaml`
- Chart metadata skeleton: `assets/chart-example.yaml`
- Chart README skeleton: `assets/README-example.md`
- Probe tuning reference: `references/probes-guide.md`
- Values organization reference: `references/configuration-guide.md`
