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
    - name: boil-xray
      listenPort: 23202
      backendHost: boil-nat.124536.xyz
      backendPort: 23202
```

默认行为：

- TCP/UDP 都启用（等价于 `tcp.enabled: true` + `udp.enabled: true`）

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

### 3) 全局超时

```yaml
nginx:
  timeouts:
    tcp:
      proxyConnectTimeout: 5s
      proxyTimeout: 60s
    udp:
      proxyTimeout: 20s
```

### 4) 端口名长度控制

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
