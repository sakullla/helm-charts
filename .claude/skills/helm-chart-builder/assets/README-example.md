# <CHART-NAME> Helm Chart

This Helm chart deploys <APPLICATION>.

## Overview

Briefly describe what the application does and key capabilities.

## Prerequisites

- Kubernetes 1.24+
- Helm 3.12+
- Any required API key or external service credentials

## Installation

### Install from local chart

```bash
helm install <RELEASE-NAME> ./charts/<CHART-NAME>
```

### Upgrade

```bash
helm upgrade <RELEASE-NAME> ./charts/<CHART-NAME>
```

### Uninstall

```bash
helm uninstall <RELEASE-NAME>
```

## Configuration

Document required values first, then common optional values.

### Required values

```yaml
secrets: {}
```

### Example values

```yaml
env: {}
secrets: {}
service:
  type: ClusterIP
  port: 8080
```

## Key Values

| Key | Description | Default |
|-----|-------------|---------|
| `image.repository` | Image repository | `<REPO>/<IMAGE>` |
| `image.tag` | Image tag | `Chart.appVersion` |
| `service.port` | Service port | `8080` |

## Validation

```bash
helm template my-release ./charts/<CHART-NAME>
helm lint ./charts/<CHART-NAME>
helm install my-release ./charts/<CHART-NAME> --dry-run --debug
```
