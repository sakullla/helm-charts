# Repository Guidelines

## Project Structure & Module Organization

This repository hosts Helm charts for self-hosted applications. Charts live under `charts/`, with one chart per directory (for example, `charts/adguard-home/`). Each chart typically contains:

- `Chart.yaml`: chart metadata and versioning.
- `values.yaml`: default configuration values with comments.
- `templates/`: Kubernetes manifests (e.g., `deployment.yaml`, `service.yaml`, `ingress.yaml`, `httproute.yaml`, `_helpers.tpl`, `NOTES.txt`).
- `tests/`: Helm test templates when applicable.

CI workflows are in `.github/workflows/`, and repository-level usage notes live in `README.md`.

## Build, Test, and Development Commands

Use Helm to render or validate changes locally:

- `helm template my-release charts/<chart-name>`: render templates to YAML for quick review.
- `helm install my-release charts/<chart-name> --dry-run --debug`: simulate an install and catch schema/template errors.
- `helm install my-release charts/<chart-name>`: install to a cluster for full validation.

## Coding Style & Naming Conventions

- Follow Helm conventions and use helpers in `templates/_helpers.tpl` for names, labels, and selectors.
- Keep values in `values.yaml` documented with clear comments.
- Standard config blocks should be supported: `replicaCount`, `image`, `service`, `ingress`, `httpRoute`, `persistence`, `resources`, `autoscaling`.
- Indentation: YAML should use 2 spaces.

## Testing Guidelines

Helm does not enforce a framework here. Use template rendering and `--dry-run --debug` to validate charts. If adding `tests/`, follow Helm test hook conventions.

## Commit & Pull Request Guidelines

- Bump `Chart.yaml` `version` for any chart change (SemVer).
- Keep `appVersion` aligned with the application image version.
- PRs should describe the chart change, include example values if behavior changes, and mention any required Kubernetes or controller versions.

## Release & CI Notes

Charts are published via GitHub Actions when `charts/**` changes on `main`. The release workflow trims old versions and tags, keeping only the most recent releases.
