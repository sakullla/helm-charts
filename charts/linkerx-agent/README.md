# linkerx-agent Helm Chart

LinkerX Agent - network monitoring platform with backend API and frontend dashboard.

## Overview

LinkerX Agent is a network monitoring solution that provides:
- Backend API server with HTTP and gRPC interfaces
- Frontend dashboard (static files served by nginx)
- Agent binary distribution with secure download links
- License-based authentication

Ingress or Gateway API handles TLS termination and routes `/api/` and `/downloads/agent/` to the backend service, while all other paths go to the frontend.

## Prerequisites

- Kubernetes 1.24+
- Helm 3.12+
- LinkerX license ID and enroll token

## Installation

### Quick install

```bash
helm install linkerx-agent ./charts/linkerx-agent \
  --set licensing.licenseId="YOUR_LICENSE_ID" \
  --set licensing.enrollToken="YOUR_ENROLL_TOKEN" \
  --set app.publicBaseUrl="https://linkerx.example.com"
```

### Install with ingress

```bash
helm install linkerx-agent ./charts/linkerx-agent \
  --set licensing.licenseId="YOUR_LICENSE_ID" \
  --set licensing.enrollToken="YOUR_ENROLL_TOKEN" \
  --set app.publicBaseUrl="https://linkerx.example.com" \
  --set persistence.enabled=true \
  --set persistence.size=10Gi \
  --set ingress.enabled=true \
  --set ingress.className=nginx \
  --set ingress.hosts[0].host=linkerx.example.com \
  --set ingress.hosts[0].paths[0].path=/ \
  --set ingress.hosts[0].paths[0].pathType=Prefix \
  --set 'ingress.tls[0].secretName=linkerx-tls' \
  --set 'ingress.tls[0].hosts[0]=linkerx.example.com'
```

### Upgrade

```bash
helm upgrade linkerx-agent ./charts/linkerx-agent
```

### Uninstall

```bash
helm uninstall linkerx-agent
```

## Configuration

### Required values

| Parameter | Description |
|-----------|-------------|
| `licensing.licenseId` | LinkerX license ID |
| `licensing.enrollToken` | LinkerX enrollment token |
| `app.publicBaseUrl` | Public base URL for agent downloads |

### Routing

| Path | Backend Service |
|------|----------------|
| `/api/` | backend (HTTP :8000) |
| `/downloads/agent/` | backend (HTTP :8000) |
| `/` (all others) | frontend (HTTP :80) |

### Example values file

```yaml
licensing:
  licenseId: "your-license-id"
  enrollToken: "your-enroll-token"

app:
  publicBaseUrl: "https://linkerx.example.com"
  grpcPort: 6080

persistence:
  enabled: true
  size: 10Gi

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: linkerx.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: linkerx-tls
      hosts:
        - linkerx.example.com
```

## Key Values

| Key | Description | Default |
|-----|-------------|---------|
| `backend.image.repository` | Backend image | `azzmb/linkerx-backend` |
| `frontend.image.repository` | Frontend image | `azzmb/linkerx-frontend` |
| `backend.service.httpPort` | Backend HTTP port | `8000` |
| `backend.service.grpcPort` | Backend gRPC port | `6080` |
| `frontend.service.port` | Frontend HTTP port | `80` |
| `persistence.enabled` | Enable persistent data storage | `false` |
| `persistence.size` | PVC size | `5Gi` |
| `app.grpcPort` | gRPC listen port in config | `6080` |

## Validation

```bash
helm template my-release ./charts/linkerx-agent
helm lint ./charts/linkerx-agent
helm install my-release ./charts/linkerx-agent --dry-run --debug
```
