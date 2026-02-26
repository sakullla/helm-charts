# Repository Guidelines

## Project Structure & Module Organization

This repository is a Helm chart monorepo.

- `charts/<chart-name>/`: one deployable chart per directory (`Chart.yaml`, `values.yaml`, `templates/`).
- `charts/<chart-name>/templates/`: Kubernetes manifests and helpers (for example `_helpers.tpl`).
- `charts/<chart-name>/templates/tests/`: optional Helm test hooks.
- `.github/workflows/`: release and publishing automation.
- Root docs: `README.md`, `CLAUDE.md`, and this guide.

## Agent Skills

- Local skills are stored in `.claude/skills/`.
- When a task references a skill, read that skill from `.claude/skills/` first, then apply it in the current repo context.

## Build, Test, and Development Commands

Use Helm CLI to validate chart changes before opening a PR:

```bash
helm template my-release charts/<chart-name>
helm install my-release charts/<chart-name> --dry-run --debug
helm show values charts/<chart-name>
```

For charts with dependencies:

```bash
helm dependency update charts/<chart-name>
```

These checks should pass with default values and at least one customized values file when behavior is configurable.

## Coding Style & Naming Conventions

- YAML uses two-space indentation and lowercase keys.
- Reuse helper templates for names/labels; avoid hardcoded metadata.
- Keep `values.yaml` organized and briefly document non-obvious options.
- Keep resource names and value keys consistent with existing charts.
- Any chart change must include a `version` bump in that chart's `Chart.yaml`.

## Testing Guidelines

There is no centralized unit-test framework for charts; validation is template/render based.

- Run `helm template` for syntax and rendering checks.
- Run `helm install --dry-run --debug` for install-time validation.
- If test hooks exist, run `helm test <release-name>` against a deployed release.

## Commit & Pull Request Guidelines

Prefer clear, scoped commit messages:

- `feat(<chart>): ...`
- `fix(<chart>): ...`
- `docs: ...`
- `chore: ...`

PRs should include: what changed, why, affected chart(s), chart version bump, and commands used for validation.

## Security & Configuration Tips

- Never hardcode credentials; expose them via values and Kubernetes Secrets.
- Gate optional components (Ingress, persistence, extra services) behind values flags.
- Document required environment variables and secret keys in `values.yaml` comments.
