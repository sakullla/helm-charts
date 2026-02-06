# Helm Chart Configuration Guide

Complete reference for values.yaml structure.

## Table of Contents

1. [Base Configuration](#base-configuration)
2. [Service Configuration](#service-configuration)
3. [Ingress](#ingress)
4. [Gateway API](#gateway-api)
5. [Health Probes](#health-probes)
6. [Resources & Scaling](#resources--scaling)
7. [Storage](#storage)
8. [Configuration Management](#configuration-management)

---

## Base Configuration

```yaml
replicaCount: 1                    # Number of pod replicas

image:
  repository: nginx                # Container image
  pullPolicy: IfNotPresent         # IfNotPresent | Always | Never
  tag: ""                          # Override appVersion

imagePullSecrets: []               # For private registries
  # - name: regcred

nameOverride: ""                   # Override chart name
fullnameOverride: ""               # Override full release name
```

## Service Account

```yaml
serviceAccount:
  create: true                     # Create service account
  automount: true                  # Auto-mount API credentials
  annotations: {}                  # IAM roles, etc.
  name: ""                         # Custom name (default: fullname)
```

## Pod Configuration

```yaml
podAnnotations: {}                 # Prometheus scraping, etc.
podLabels: {}                      # Additional labels

podSecurityContext:                # Pod-level security
  fsGroup: 2000
  runAsNonRoot: true

securityContext:                   # Container-level security
  capabilities:
    drop:
    - ALL
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 1000
```

## Service Configuration

```yaml
service:
  type: ClusterIP                  # ClusterIP | NodePort | LoadBalancer
  port: 80                         # Service port
  nodePort: 30080                  # Only for NodePort
  annotations: {}                  # Cloud provider annotations
```

## Ingress

```yaml
ingress:
  enabled: false
  className: nginx                 # ingress-nginx, traefik, etc.
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt
  hosts:
    - host: api.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: api-tls
      hosts:
        - api.example.com
```

## Gateway API

```yaml
httpRoute:
  enabled: false
  annotations: {}
  parentRefs:
    - name: gateway
      sectionName: http
      namespace: default
  hostnames:
    - api.example.com
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /
```

## Health Probes

### Startup Probe

```yaml
startupProbe:
  tcpSocket:                       # Fast startup detection
    port: http
  initialDelaySeconds: 5
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 6              # 6 * 10s = 60s max startup
```

### Liveness Probe

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: http
  initialDelaySeconds: 10
  periodSeconds: 30
  timeoutSeconds: 10
  failureThreshold: 3
```

### Readiness Probe

```yaml
readinessProbe:
  httpGet:
    path: /ready
    port: http
  initialDelaySeconds: 5
  periodSeconds: 30
  timeoutSeconds: 10
  failureThreshold: 3
```

## Resources & Scaling

```yaml
resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 100m
    memory: 128Mi

autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
  targetMemoryUtilizationPercentage: 80
  # Custom metrics (optional)
  metrics: []
    # - type: Pods
    #   pods:
    #     metric:
    #       name: packets-per-second
    #     target:
    #       type: AverageValue
    #       averageValue: 1k
  # Scaling behavior (optional)
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
        - type: Percent
          value: 10
          periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
        - type: Percent
          value: 100
          periodSeconds: 15
```

## Storage

### Persistent Volume Claim

```yaml
persistence:
  enabled: false
  size: 10Gi
  storageClass: "standard"         # "-" for default
  accessMode: ReadWriteOnce
  existingClaim: ""                # Use existing PVC
  annotations: {}                  # PV annotations
  volumeMode: Filesystem           # Filesystem | Block
  selector: {}                     # Label selector for PV
```

### Additional Volumes

```yaml
volumes: []                        # Additional volumes
  - name: config
    configMap:
      name: my-config

volumeMounts: []                   # Container mounts
  - name: data
    mountPath: /data
```

## Configuration Management

### ConfigMap (Non-sensitive)

```yaml
env:
  LOG_LEVEL: info
  PORT: "8080"
  CACHE_TTL: "300"
```

### Secret (Sensitive)

```yaml
secrets:
  API_KEY: "sk-xxx"
  DATABASE_URL: "postgres://..."
```

### Extra Environment Variables

```yaml
extraEnv:
  - name: SPECIAL_VAR
    value: "value"
  - name: POD_NAME
    valueFrom:
      fieldRef:
        fieldPath: metadata.name
```

## Dependencies

```yaml
# valkey (Redis alternative)
valkey:
  enabled: false
  replica:
    enabled: false               # standalone mode
  auth:
    enabled: false
  dataStorage:
    enabled: true
    requestedSize: 1Gi

# postgresql
postgresql:
  enabled: false
  auth:
    postgresPassword: changeme
  primary:
    persistence:
      size: 8Gi
```
