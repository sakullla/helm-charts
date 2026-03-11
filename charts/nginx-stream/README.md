# nginx-stream Helm Chart

这个 Chart 用于部署基于 Nginx `stream` 的 TCP/UDP 转发服务。

## 设计说明

- 单一配置源：只维护 `values.yaml` 中的 `nginx.forwards`，其余内容自动渲染
- 自动渲染内容：
  - `ConfigMap` 里的 `nginx.conf`
  - Deployment 的容器端口
  - Service 的端口
- 健康检查端口：自动取第一条“TCP 启用”的 forward 端口
- `tcp.enabled` / `udp.enabled` 默认 `true`，不写也会启用
- 支持全局协议默认开关：`nginx.protocolDefaults.tcpEnabled/udpEnabled`
- 支持单后端兼容配置 `backendHost/backendPort`，也支持多后端 `backends[]`
- 支持 `loadBalancing.strategy` 配置 upstream 负载均衡策略
- 当后端是域名时，会自动启用 NGINX `resolve`，适配 DDNS 变更
- 超时为全局配置：`nginx.timeouts.*`

## 快速使用

```bash
helm template my-release charts/nginx-stream
helm lint charts/nginx-stream
helm install my-release charts/nginx-stream --dry-run=client --debug
```

## 核心配置

### 1) 转发规则（唯一需要重点维护的部分）

```yaml
nginx:
  forwards:
    - name: demo-forward
      listenPort: 23202
      backendHost: upstream.example.com
      backendPort: 23202
```

默认行为：

- TCP/UDP 都启用（等价于 `tcp.enabled: true` + `udp.enabled: true`）
- 单后端会自动转换成 upstream 配置，便于后续扩展到多后端和域名动态解析

多后端示例：

```yaml
nginx:
  forwards:
    - name: demo-forward
      listenPort: 23202
      backendPort: 23202
      backends:
        - host: stream-a.example.com
        - host: stream-b.example.com
```

### 2) 协议开关（可选）

全局默认：

```yaml
nginx:
  protocolDefaults:
    tcpEnabled: true
    udpEnabled: true
```

```yaml
nginx:
  forwards:
    - name: only-tcp
      listenPort: 30001
      backendHost: example.com
      backendPort: 30001
      udp:
        enabled: false
```

`forward` 上的 `tcp.enabled/udp.enabled` 会覆盖全局默认值。

### 3) 负载均衡策略

默认是 `round_robin`。可选值：

- `round_robin`
- `least_conn`
- `random`
- `hash`（需要额外指定 `hashKey`）

```yaml
nginx:
  forwards:
    - name: demo
      listenPort: 30000
      backendPort: 30000
      backends:
        - host: stream-a.example.com
          weight: 2
        - host: stream-b.example.com
      loadBalancing:
        strategy: least_conn
        zoneSize: 64k
```

按客户端地址做一致性路由：

```yaml
nginx:
  forwards:
    - name: sticky-demo
      listenPort: 30001
      backendPort: 30001
      backends:
        - host: node-a.example.com
        - host: node-b.example.com
      loadBalancing:
        strategy: hash
        hashKey: $remote_addr
```

### 4) DDNS / 域名后端

- `backendHost` 或 `backends[].host` 为域名时，Chart 会为 upstream 自动加 `resolve`
- 仍然需要配置 `nginx.resolver`，用于运行时 DNS 解析
- `backends[].resolve` 可显式覆盖自动判断

```yaml
nginx:
  resolver: 1.1.1.1 8.8.8.8 valid=30s ipv6=off
  forwards:
    - name: ddns-demo
      listenPort: 32000
      backendPort: 32000
      backends:
        - host: node-a.example.com
        - host: node-b.example.com
          resolve: true
      loadBalancing:
        strategy: round_robin
```

### 5) 全局超时

```yaml
nginx:
  timeouts:
    tcp:
      proxyConnectTimeout: 5s
      proxyTimeout: 60s
    udp:
      proxyTimeout: 20s
```

### 6) 端口名长度控制

```yaml
portName:
  maxLength: 15
```

- 端口名由系统基于 `forward.name` 自动生成
- 支持配置长度，Chart 会自动限制为 Kubernetes 安全范围（不超过 15）

## 可选 NodePort

当 `service.type=NodePort` 时，可按协议分别指定：

```yaml
service:
  type: NodePort

nginx:
  forwards:
    - name: demo
      listenPort: 30000
      backendHost: example.com
      backendPort: 30000
      tcp:
        nodePort: 32000
      udp:
        nodePort: 32001
```
