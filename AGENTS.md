# Repository Guidelines

## Project Structure & Module Organization
This repository is a Helm chart monorepo. Each deployable app lives in `charts/<chart-name>/` with `Chart.yaml`, `values.yaml`, and `templates/`. Keep chart logic isolated to its own folder.

Typical template files include `deployment.yaml`, `service.yaml`, `ingress.yaml`, `httproute.yaml`, `hpa.yaml`, and `_helpers.tpl`. Many charts also include `templates/tests/test-connection.yaml` for Helm test hooks. CI/release automation lives in `.github/workflows/release.yml`.

## Build, Test, and Development Commands
Run commands from repository root:

- `helm lint charts/<chart-name>`: static chart validation.
- `helm template <release> charts/<chart-name> --debug`: render manifests locally.
- `helm install <release> charts/<chart-name> --dry-run --debug -n <ns> --create-namespace`: simulate installation.
- `helm dependency update charts/<chart-name>`: refresh dependencies (required for charts like `automem`).
- `helm package charts/<chart-name>`: verify chart packaging.

## Coding Style & Naming Conventions
Use 2-space YAML indentation and lowercase kebab-case for chart names and most values keys. Reuse helper templates for naming/labels instead of hardcoding metadata.

Name helpers with a chart prefix, for example `{{ define "vaultwarden.fullname" }}`. Keep `values.yaml` grouped by functional sections (image, service, ingress/httpRoute, persistence, resources, env, secrets).

## Testing Guidelines
There is no centralized unit test framework; validation is Helm-based. For every chart change, run `helm lint`, `helm template`, and a dry-run install. If chart test hooks exist, keep the test file name as `templates/tests/test-connection.yaml` and validate it with a real install plus `helm test <release>` when possible.

## Commit & Pull Request Guidelines
Git history shows Conventional Commit usage (for example `feat(automem): ...`, `fix(nginx-stream): ...`). Follow that format with chart scope.

For PRs, include: purpose, affected chart paths, validation commands run, and any breaking values changes. If a chart is modified, bump `version` in that chart's `Chart.yaml`; update `appVersion` when upstream app version changes.

## Security & Configuration Tips
Never commit real secrets in `values.yaml`. Use placeholders and inject sensitive data via Kubernetes Secrets or external secret managers.