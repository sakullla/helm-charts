# Repository Guidelines

## Project Structure & Module Organization

- `charts/` contains all Helm charts. Each chart lives at `charts/<chart-name>/` with `Chart.yaml`, `values.yaml`, and `templates/`.
- `templates/` holds Kubernetes manifests and helpers like `_helpers.tpl`; optional `tests/` may exist for Helm tests.
- `.github/workflows/` drives chart release automation and publishing to GitHub Pages.
- Top-level docs live in `README.md` and `CLAUDE.md`.

## Build, Test, and Development Commands

Use Helm for local validation:

```bash
# Render templates (quick syntax check)
helm template my-release charts/<chart-name>

# Validate with install simulation
helm install my-release charts/<chart-name> --dry-run --debug

# View defaults
helm show values charts/<chart-name>
```

If a chart has dependencies:

```bash
helm dependency update charts/<chart-name>
```

## Coding Style & Naming Conventions

- Follow existing Helm/YAML patterns in `charts/*` (two-space indentation, lowercase keys, and consistent ordering in `values.yaml`).
- Use helpers from `_helpers.tpl` for names/labels instead of hardcoding.
- Keep `values.yaml` documented with brief inline comments.
- Always bump `Chart.yaml` `version` when any chart file changes.

## Testing Guidelines

- There is no centralized test framework; validate by rendering and dry-run installing.
- If a chart includes Helm tests under `templates/tests/`, run:
  ```bash
  helm test <release-name>
  ```
- Ensure chart installs cleanly with defaults and at least one customized values file when relevant.

## Commit & Pull Request Guidelines

- Git history is mixed: many commits are terse (`1`) and some use prefixes like `docs:` or `chore:`. Prefer clear, scoped messages.
- Recommended format: `feat(<chart>): ...`, `fix(<chart>): ...`, `docs: ...`, `chore: ...`.
- PRs should describe the chart change, include the bumped chart version, and note validation commands run (e.g., `helm template`, `--dry-run --debug`).

## Security & Configuration Tips

- Do not hardcode secrets. Use values (or Kubernetes secrets) and document expected keys in `values.yaml`.
- Prefer conditional templates for optional features (Ingress, HTTPRoute, persistence) to keep defaults minimal.
