# falkordb Helm Chart

This chart deploys a standalone FalkorDB instance with Redis protocol access and optional Browser HTTP access.

`FALKORDB_GRAPH` should be configured in AutoMem (client) rather than in this FalkorDB server chart.

## Prerequisites

- Kubernetes 1.24+
- Helm 3.12+

## Installation

```bash
helm install falkordb ./charts/falkordb
```

## Example values

```yaml
service:
  exposeBrowserPort: true

secrets:
  REDIS_PASSWORD: "change-me"
```

## Configuration

Key values:

| Key | Description | Default |
|-----|-------------|---------|
| `image.repository` | FalkorDB image repository | `falkordb/falkordb` |
| `image.tag` | Image tag | `Chart.appVersion` (`v4.16.5`) |
| `service.redisPort` | Redis service/container port | `6379` |
| `service.browserPort` | Browser service/container port | `3000` |
| `service.exposeBrowserPort` | Expose browser port on service/pod | `true` |
| `secrets.REDIS_PASSWORD` | Optional Redis password | `""` |
| `persistence.enabled` | Enable PVC for data directory | `true` |
| `persistence.size` | PVC requested size | `10Gi` |
| `ingress.enabled` | Enable Ingress for browser endpoint | `false` |
| `httpRoute.enabled` | Enable Gateway API HTTPRoute for browser endpoint | `false` |

## Validation

```bash
helm template my-release ./charts/falkordb
helm lint ./charts/falkordb
helm install my-release ./charts/falkordb --dry-run --debug
```
