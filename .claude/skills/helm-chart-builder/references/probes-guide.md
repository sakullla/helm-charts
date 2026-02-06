# Health Probes Best Practices

## Probe Types Overview

| Probe | Purpose | When to Use |
|-------|---------|-------------|
| **startupProbe** | Detect when app has started | Long-starting apps (>10s) |
| **livenessProbe** | Detect deadlocks/hangs | Always |
| **readinessProbe** | Detect when app can serve traffic | Always |

## Startup Probe

**Purpose**: Disable liveness/readiness checks during startup.

**Recommended**: Use `tcpSocket` for fastest detection.

```yaml
startupProbe:
  tcpSocket:
    port: http
  initialDelaySeconds: 5      # Wait before first check
  periodSeconds: 10           # Check interval
  timeoutSeconds: 5           # Response timeout
  failureThreshold: 6         # Max failures before restart
  # Total startup time: 5 + (6 * 10) = 65s
```

**When to use longer thresholds:**
- JVM apps: 30-60s startup
- ML models: 60-120s startup
- Legacy apps: 30-90s startup

## Liveness Probe

**Purpose**: Restart container if app is deadlocked.

**Recommended**: HTTP endpoint that tests core functionality.

```yaml
livenessProbe:
  httpGet:
    path: /health             # Simple health check
    port: http
  initialDelaySeconds: 10     # After startup completes
  periodSeconds: 30           # Check every 30s
  timeoutSeconds: 10          # Request timeout
  failureThreshold: 3         # 3 failures = restart
  # Total failure time: 3 * 30 = 90s
```

**Best practices:**
- Use simple endpoint (don't query database)
- Set periodSeconds >= 10 (avoid spam)
- Don't set too aggressive (causes unnecessary restarts)

## Readiness Probe

**Purpose**: Remove pod from service endpoints when not ready.

**Recommended**: HTTP endpoint that tests dependencies.

```yaml
readinessProbe:
  httpGet:
    path: /ready              # Deep health check
    port: http
  initialDelaySeconds: 5
  periodSeconds: 30
  timeoutSeconds: 10
  failureThreshold: 3
```

**Best practices:**
- Check database connectivity if required
- Fail readiness (not liveness) for dependency issues
- Allow pod to recover without restart

## Probe Patterns

### Pattern 1: Simple Web Service

```yaml
# Startup: tcpSocket (fast)
# Liveness: /health (light)
# Readiness: /health (light)

startupProbe:
  tcpSocket:
    port: http
  periodSeconds: 5
  failureThreshold: 12        # 60s max startup

livenessProbe:
  httpGet:
    path: /health
    port: http
  periodSeconds: 10
  failureThreshold: 3

readinessProbe:
  httpGet:
    path: /health
    port: http
  periodSeconds: 5
  failureThreshold: 3
```

### Pattern 2: Database-Dependent App

```yaml
# Startup: tcpSocket
# Liveness: /health (no DB check)
# Readiness: /ready (with DB check)

startupProbe:
  tcpSocket:
    port: http
  periodSeconds: 5
  failureThreshold: 12

livenessProbe:
  httpGet:
    path: /health            # Lightweight
    port: http
  periodSeconds: 10
  failureThreshold: 3

readinessProbe:
  httpGet:
    path: /ready             # Checks DB connection
    port: http
  periodSeconds: 5
  failureThreshold: 3
```

### Pattern 3: Long-Starting App

```yaml
# Startup: httpGet (wait for full initialization)
# Liveness/Readiness: standard

startupProbe:
  httpGet:
    path: /health
    port: http
  initialDelaySeconds: 10
  periodSeconds: 5
  failureThreshold: 30        # 150s max startup

livenessProbe:
  httpGet:
    path: /health
    port: http
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /ready
    port: http
  periodSeconds: 5
```

## Common Mistakes

### ❌ Too Aggressive

```yaml
# Bad - causes frequent restarts
livenessProbe:
  periodSeconds: 1            # Too frequent
  failureThreshold: 1         # Too sensitive
  timeoutSeconds: 1           # Too short
```

### ✅ Balanced

```yaml
# Good - stable and responsive
livenessProbe:
  periodSeconds: 10           # Check every 10s
  failureThreshold: 3         # 30s before restart
  timeoutSeconds: 5           # 5s timeout
```

### ❌ Missing Startup Probe

```yaml
# Bad - liveness kills app during startup
livenessProbe:
  initialDelaySeconds: 60     # Guess startup time
```

### ✅ With Startup Probe

```yaml
# Good - startup probe handles variable startup
startupProbe:
  tcpSocket:
    port: http
  failureThreshold: 30        # Up to 300s
livenessProbe:
  # No initialDelaySeconds needed
  periodSeconds: 10
```

## Quick Reference Table

| App Type | Startup | Liveness | Readiness |
|----------|---------|----------|-----------|
| Go/Node.js | tcpSocket, 10s | /health, 10s | /health, 5s |
| Python | tcpSocket, 10s | /health, 10s | /ready, 5s |
| Java | tcpSocket, 30s | /health, 30s | /ready, 10s |
| ML/AI | httpGet, 60s | /health, 30s | /ready, 10s |
