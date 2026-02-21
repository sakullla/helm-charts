# Helm Chart Configuration Guide

Reference for `values.yaml` used by `helm-chart-builder`.

## Table of Contents

1. [Base Configuration](#base-configuration)
2. [Service Account and Pod](#service-account-and-pod)
3. [Service and Traffic](#service-and-traffic)
4. [Health Probes](#health-probes)
5. [Resources and Scaling](#resources-and-scaling)
6. [Storage](#storage)
7. [Config and Secrets](#config-and-secrets)

## Base Configuration

```yaml
replicaCount: 1

image:
  repository: ghcr.io/example/app
  pullPolicy: IfNotPresent
  tag: ""                        # Defaults to Chart.appVersion

imagePullSecrets: []
nameOverride: ""
fullnameOverride: ""

# Optional container startup overrides
command: []
args: []
```

## Service Account and Pod

```yaml
serviceAccount:
  create: true
  automount: true
  annotations: {}
  name: ""

podAnnotations: {}
podLabels: {}

podSecurityContext: {}
securityContext: {}

nodeSelector: {}
tolerations: []
affinity: {}
```

## Service and Traffic

```yaml
service:
  annotations: {}
  type: ClusterIP               # ClusterIP | NodePort | LoadBalancer
  port: 8080
  # nodePort: 30080             # Only for NodePort
```

```yaml
ingress:
  enabled: false
  className: ""
  annotations: {}
  hosts:
    - host: chart-example.local
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls: []
```

```yaml
httpRoute:
  enabled: false
  annotations: {}
  parentRefs:
    - name: gateway
      sectionName: http
  hostnames:
    - chart-example.local
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /
```

## Health Probes

`startupProbe` uses TCP probing (`tcpSocket`) by default. This is the preferred baseline for charts in this repo.

```yaml
startupProbe:
  tcpSocket:
    port: http
  failureThreshold: 30
  periodSeconds: 10
  timeoutSeconds: 5
  successThreshold: 1
```

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

## Resources and Scaling

```yaml
resources: {}
  # limits:
  #   cpu: 100m
  #   memory: 128Mi
  # requests:
  #   cpu: 100m
  #   memory: 128Mi

autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 100
  targetCPUUtilizationPercentage: 80
  # targetMemoryUtilizationPercentage: 80
```

## Storage

```yaml
persistence:
  enabled: false
  size: 1Gi
  storageClass: ""
  accessMode: ReadWriteOnce
  existingClaim: ""
  annotations: {}
```

```yaml
volumes: []
volumeMounts: []
```

## Config and Secrets

Use ConfigMap for non-sensitive variables and Secret for credentials.

```yaml
env:
  PORT: "8080"
  LOG_LEVEL: info
```

```yaml
secrets:
  APP_API_KEY: ""
  DATABASE_URL: ""
```

Optional extra `env` entries:

```yaml
extraEnv: []
# - name: POD_NAME
#   valueFrom:
#     fieldRef:
#       fieldPath: metadata.name
```
