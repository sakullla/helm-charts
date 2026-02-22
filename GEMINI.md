# Gemini CLI Context for Helm Charts Repository

This file defines the core context, guidelines, and commands for developing within the `sakullla/helm-charts` repository. It is based directly on the project's `AGENTS.md`.

## Project Structure & Module Organization
- **`charts/`**: The core directory containing all Helm charts. Each chart is located at `charts/<chart-name>/` and includes a `Chart.yaml`, `values.yaml`, and a `templates/` directory.
- **`templates/`**: Contains Kubernetes manifests, helpers like `_helpers.tpl`, and optionally a `tests/` directory for Helm tests.
- **`.github/workflows/`**: Contains CI/CD automation for releasing charts and publishing them to GitHub Pages.
- **Documentation**: Top-level documentation resides in `README.md` and `CLAUDE.md`.

## Build, Test, and Development Commands
Use Helm commands for local validation before committing changes:

```bash
# Render templates to check syntax quickly
helm template my-release charts/<chart-name>

# Simulate an installation to validate the chart
helm install my-release charts/<chart-name> --dry-run --debug

# View default configuration values
helm show values charts/<chart-name>

# Update dependencies if a chart relies on others
helm dependency update charts/<chart-name>
```

## Coding Style & Naming Conventions
- **YAML Formatting**: Adhere to existing Helm and YAML patterns found in `charts/*` (e.g., two-space indentation, lowercase keys, and consistent key ordering in `values.yaml`).
- **Helpers**: Always utilize helpers from `_helpers.tpl` for generating names and labels instead of hardcoding strings.
- **Documentation**: Keep `values.yaml` well-documented with brief inline comments.
- **Version Bumping (CRITICAL)**: Always increment the `version` field in `Chart.yaml` whenever any file within that chart is modified.

## Testing Guidelines
- **No Central Framework**: The project does not use a centralized testing framework. Validation relies on `helm template` and `helm install --dry-run`.
- **Helm Tests**: If a chart includes tests under `templates/tests/`, they can be run using:
  ```bash
  helm test <release-name>
  ```
- **Validation**: Ensure the chart installs cleanly using its default values, as well as with at least one customized values file when relevant to the changes made.

## Commit & Pull Request Guidelines
- **Commit Messages**: Prefer clear, scoped, and conventional commit messages. Recommended format:
  - `feat(<chart-name>): <description>`
  - `fix(<chart-name>): <description>`
  - `docs: <description>`
  - `chore: <description>`
- **Pull Requests**: PR descriptions should detail the chart changes, confirm that the chart version was bumped, and list the validation commands executed (e.g., `helm template`, `--dry-run --debug`).

## Security & Configuration Tips
- **Secrets Management**: Never hardcode sensitive information. Rely on values or external Kubernetes Secrets, and clearly document the expected keys within `values.yaml`.
- **Optional Features**: Use conditional templates for optional features (such as Ingress, HTTPRoute, and persistence) to ensure the default configuration remains minimal and clean.
