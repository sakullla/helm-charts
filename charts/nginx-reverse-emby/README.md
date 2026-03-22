# nginx-reverse-emby Helm Chart

This Helm chart deploys nginx-reverse-emby, an automated reverse proxy solution for Emby, Jellyfin and various HTTP/TCP services.

## Overview

nginx-reverse-emby is a comprehensive reverse proxy solution featuring:
- Visual panel management for HTTP/L4 rules
- Automatic SSL certificate management with acme.sh
- Support for HTTP/DNS API validation (Cloudflare, etc.)
- IPv4/IPv6 dual-stack support
- Master/Agent architecture for managing multiple Nginx nodes
- Dynamic configuration with automatic reload

## Prerequisites

- Kubernetes 1.24+
- Helm 3.12+
- Persistent storage for certificates and configuration data
- (Optional) Cloudflare API token for DNS-based SSL validation

## Installation

### Install from this repository

```bash
helm repo add sakullla https://sakullla.github.io/helm-charts
helm repo update
helm install my-nginx-reverse-emby sakullla/nginx-reverse-emby
```

### Install from local chart

```bash
helm install my-nginx-reverse-emby ./charts/nginx-reverse-emby
```

### Upgrade

```bash
helm upgrade my-nginx-reverse-emby sakullla/nginx-reverse-emby
```

### Uninstall

```bash
helm uninstall my-nginx-reverse-emby
```

## Configuration

### Required values

```yaml
secrets:
  API_TOKEN: "your-secure-api-token"
```

### Example values for master node (front_proxy mode)

```yaml
image:
  repository: sakullla/nginx-reverse-emby
  tag: latest

service:
  type: ClusterIP
  panelPort: 8080
  proxyPort: 3000

persistence:
  enabled: true
  size: 5Gi

panel:
  role: master
  deployMode: front_proxy
  autoApply: true

# Ingress for reverse proxy traffic
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: example.com
      paths:
        - path: /
          pathType: Prefix

secrets:
  API_TOKEN: "your-secure-api-token"
```

### Example values for agent node

```yaml
panel:
  role: agent

master:
  registerToken: "your-register-token"

secrets:
  API_TOKEN: "your-secure-api-token"
  MASTER_REGISTER_TOKEN: "your-register-token"
```

## Key Values

| Key | Description | Default |
|-----|-------------|---------|
| `image.repository` | Image repository | `sakullla/nginx-reverse-emby` |
| `image.tag` | Image tag | `Chart.appVersion` |
| `service.panelPort` | Panel management port | `8080` |
| `service.proxyPort` | Reverse proxy port (front_proxy mode) | `3000` |
| `persistence.enabled` | Enable persistent storage | `true` |
| `persistence.size` | Storage size | `5Gi` |
| `panel.role` | Panel role (master/agent) | `master` |
| `panel.deployMode` | Deploy mode (direct/front_proxy) | `front_proxy` |
| `panel.autoApply` | Auto apply config changes | `true` |
| `acme.email` | ACME registration email | `""` |
| `acme.ca` | Certificate authority | `letsencrypt` |
| `acme.dnsProvider` | DNS provider for validation | `""` |

## Deploy Modes

- **front_proxy** (default, recommended for Kubernetes): External Ingress/Gateway handles SSL termination, container does reverse proxy on port 3000
- **direct**: Container directly handles SSL termination on ports 80/443 (not recommended for Kubernetes)

## Validation

```bash
helm template my-release ./charts/nginx-reverse-emby
helm lint ./charts/nginx-reverse-emby
helm install my-release ./charts/nginx-reverse-emby --dry-run --debug
```

## Access

### Management Panel
Access the management panel at:
- `http://<service-ip>:8080` (if using ClusterIP with port-forward)
- `kubectl port-forward svc/<release-name>-nginx-reverse-emby 8080:8080`

Login with the `API_TOKEN` you configured in secrets.

### Reverse Proxy Traffic
In front_proxy mode (default):
- Configure Ingress or HTTPRoute to route traffic to service port 3000
- The container handles reverse proxy logic without SSL termination
- External Ingress Controller manages SSL/TLS certificates

Example Ingress configuration:
```yaml
ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt
  hosts:
    - host: example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: example-com-tls
      hosts:
        - example.com
```
