# Health Probes Guide

Probe defaults in this skill follow repository practice:
- `startupProbe`: TCP probe (`tcpSocket`) for fast startup detection.
- `livenessProbe`: HTTP check for process health.
- `readinessProbe`: HTTP check for traffic readiness.

## Startup Probe (TCP)

Use TCP probing when you only need to know whether the app port is accepting connections.

```yaml
startupProbe:
  tcpSocket:
    port: http
  failureThreshold: 30
  periodSeconds: 10
  timeoutSeconds: 5
  successThreshold: 1
```

Notes:
- This is the Kubernetes equivalent of a TCP ping.
- Total startup window is roughly `failureThreshold * periodSeconds` (300s above).
- Increase `failureThreshold` for slow-starting workloads.

## Liveness Probe (HTTP)

Use a lightweight endpoint that reflects process health.

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: http
  initialDelaySeconds: 15
  periodSeconds: 20
  timeoutSeconds: 5
  successThreshold: 1
  failureThreshold: 3
```

## Readiness Probe (HTTP)

Use an endpoint that indicates whether the pod can receive traffic.

```yaml
readinessProbe:
  httpGet:
    path: /ready
    port: http
  initialDelaySeconds: 5
  periodSeconds: 10
  timeoutSeconds: 5
  successThreshold: 1
  failureThreshold: 3
```

## When to Use HTTP Startup Probe Instead

Switch `startupProbe` to `httpGet` when port-open is not enough, such as:
- model preload or warm-up must finish before healthy
- database migration must complete on startup
- app accepts TCP but still returns startup errors

Example:

```yaml
startupProbe:
  httpGet:
    path: /ready
    port: http
  failureThreshold: 30
  periodSeconds: 10
  timeoutSeconds: 5
```

## Common Mistakes

Bad:

```yaml
livenessProbe:
  periodSeconds: 1
  failureThreshold: 1
  timeoutSeconds: 1
```

Better:

```yaml
livenessProbe:
  periodSeconds: 10
  failureThreshold: 3
  timeoutSeconds: 5
```
