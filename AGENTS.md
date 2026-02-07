# AGENTS.md

## Purpose

This repository stores Helm charts for self-hosted applications under `charts/`.
The goal of this guide is to make chart changes consistent, reviewable, and releasable.

## Repository Layout

- `charts/<chart-name>/Chart.yaml`: chart metadata, `version`, `appVersion`.
- `charts/<chart-name>/values.yaml`: defaults and user-facing configuration.
- `charts/<chart-name>/templates/`: manifests and helpers (for example `_helpers.tpl`).
- `charts/<chart-name>/tests/`: optional Helm test templates.
- `.github/workflows/`: release/publish automation.

## Non-Negotiable Rules (Must Follow)

1. Any change under `charts/<chart-name>/` MUST bump `charts/<chart-name>/Chart.yaml` `version` (SemVer).
2. If the chart default image/application version changes, update `appVersion` accordingly.
3. `values.yaml` keys added or changed MUST be documented with concise comments.
4. YAML indentation MUST be 2 spaces (no tabs).
5. Reuse naming/labels/selectors helpers in `_helpers.tpl`; avoid duplicating label/name logic in multiple templates.
6. Do not mix unrelated refactors with functional chart changes in one PR unless explicitly requested.

## Standard Values Compatibility

When reasonable for the chart, keep support for these common blocks and naming:

- `replicaCount`
- `image`
- `service`
- `ingress`
- `httpRoute`
- `persistence`
- `resources`
- `autoscaling`

If a chart intentionally does not support one of these blocks, document that in chart README/notes.

## Change Workflow (Agent Checklist)

For each changed chart:

1. Identify chart scope:
   - Which files changed?
   - Is behavior changed or only metadata/docs?
2. Update versions:
   - Bump `Chart.yaml` `version`.
   - Align `appVersion` if app/image version changed.
3. Validate template quality:
   - Prefer helpers for names/labels/selectors.
   - Keep labels/selectors stable unless change is intentional and documented.
   - Check `ingress`/`httpRoute` rendering logic for compatibility.
4. Validate defaults:
   - New values have comments.
   - Defaults are safe and installable.
5. Run local validation commands:
   - `helm template my-release charts/<chart-name>`
   - `helm install my-release charts/<chart-name> --dry-run --debug`
6. Summarize impact:
   - User-facing behavior changes.
   - Required Kubernetes/controller assumptions.
   - Any migration notes.

## Validation Commands

Use these commands from repository root:

- Render:
  - `helm template my-release charts/<chart-name>`
- Dry-run install:
  - `helm install my-release charts/<chart-name> --dry-run --debug`
- Optional real install validation:
  - `helm install my-release charts/<chart-name>`

If multiple charts were changed, run validation for each changed chart.

## PR / Commit Expectations

### Commit

- Keep commits scoped and readable.
- Commit message should state chart + intent.
  - Example: `feat(adguard-home): add httpRoute support`
  - Example: `fix(adguard-home): correct service selector labels`
  - Example: `chore(adguard-home): bump chart version to 1.2.4`

### Pull Request Description

PR should include:

1. What changed (templates/values/behavior).
2. Why it changed.
3. Version updates:
   - old/new `Chart.yaml` `version`
   - old/new `appVersion` (if applicable)
4. Example values for new options.
5. Validation evidence:
   - commands run
   - key output/result summary
6. Compatibility notes:
   - minimum Kubernetes version if relevant
   - ingress controller / Gateway API assumptions if relevant

## Common Risk Checks

Before finalizing, explicitly check:

1. Selector drift: service selector still matches workload labels.
2. Name drift: fullname helpers still produce expected resource names.
3. Conditional resources: toggles (`ingress.enabled`, `httpRoute.enabled`, `autoscaling.enabled`, etc.) render cleanly on/off.
4. Persistence changes: PVC names and mount paths remain stable unless intentionally changed.
5. Breaking defaults: changed ports, probes, or paths are called out.

## Agent Response Style for This Repo

When proposing or applying chart changes, always report:

1. Which chart(s) were touched.
2. Whether `Chart.yaml` version bump was done.
3. Whether `appVersion` update was needed/done.
4. Which Helm validation commands were run and results.
5. Any known risks or follow-up actions.

## Release Context

Charts are published by GitHub Actions when `charts/**` changes on `main`.
Assume chart version correctness is release-critical.
