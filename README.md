# Helm Charts 仓库

[![Release Charts](https://github.com/sakullla/helm-charts/actions/workflows/release.yml/badge.svg)](https://github.com/sakullla/helm-charts/actions/workflows/release.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)

精选的 Kubernetes Helm Charts 集合，包含 40+ 种自托管应用。

## 快速开始

```bash
# 添加仓库
helm repo add sakullla https://sakullla.github.io/helm-charts
helm repo update

# 搜索可用的 Charts
helm search repo sakullla

# 安装应用
helm install my-app sakullla/<chart-name>
```

## 可用 Charts

### 基础设施工具

- **adguard-home** - 网络级广告拦截 DNS 服务器
- **ddns-go** - 动态 DNS 自动更新
- **dns-server** - 轻量级 DNS 服务器
- **frp** - 快速反向代理（内网穿透）
- **headscale** - Tailscale 开源控制服务器
- **headplane** - Headscale Web 管理界面

### AI 与聊天

- **lobehub** - Lobe Chat AI 聊天界面
- **astrbot** - 多平台聊天机器人框架
- **kirara-agent** - Kirara AI Agent
- **newapi** - OneAPI 分支，AI API 网关

### 开发工具

- **browserless-chromium** - 无头浏览器服务
- **playwright-service** - Playwright 自动化测试
- **hubproxy** - Docker Hub 镜像代理
- **hugo-site** - Hugo 静态网站生成器

### 知识管理

- **affine** - 下一代知识库工具（Notion 替代）
- **hedgedoc** - 实时协作 Markdown 编辑器
- **chartdb** - 数据库 ER 图可视化

### 媒体娱乐

- **kavita** - 电子书、漫画阅读器
- **qbittorrent** - BitTorrent 客户端
- **calibre-web-automated** - Calibre Web 界面
- **ani-rss** - 动漫 RSS 自动下载
- **yamtrack** - 媒体追踪工具
- **misaka-danmu-server** - 弹幕服务器

### 网络工具

- **firecrawl** - 网页爬虫和数据提取
- **searxng** - 隐私保护元搜索引擎
- **xray** - 代理工具
- **substore** - 订阅转换工具
- **miaospeed** - 网络速度测试

### 安全工具

- **vaultwarden** - Bitwarden 密码管理器
- **certimate** - SSL 证书自动化管理

### 其他

- **saveany-bot** - 内容保存机器人
- **logvar** - 日志收集工具
- **tabby-web** - Web 终端
- **openlist** / **oplist-api** - 列表管理

## 配置指南

### 通用配置

所有 Charts 支持以下配置项：

```yaml
# 镜像配置
image:
  repository: app/image
  tag: "latest"
  pullPolicy: IfNotPresent

# 副本数
replicaCount: 1

# 资源限制
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi

# 持久化存储
persistence:
  enabled: true
  size: 5Gi
  storageClass: "longhorn"  # 或其他存储类
  accessMode: ReadWriteOnce

# 环境变量（ConfigMap）
env:
  TZ: "Asia/Shanghai"
  LOG_LEVEL: "info"

# 敏感信息（Secret）
secrets:
  DATABASE_URL: "postgresql://user:pass@host:5432/db"
  API_KEY: "your-secret-key"
```

### 网络访问

#### 1. Ingress（推荐）

```yaml
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: app.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: app-tls
      hosts:
        - app.example.com
```

#### 2. Gateway API HTTPRoute

```yaml
httpRoute:
  enabled: true
  parentRefs:
    - name: gateway
      namespace: kube-system
  hostnames:
    - app.example.com
```

#### 3. NodePort / LoadBalancer

```yaml
service:
  type: NodePort  # 或 LoadBalancer
  port: 80
```

## 应用配置示例

### AdGuard Home (广告拦截)

```bash
helm install adguard sakullla/adguard-home -f - <<EOF
persistence:
  enabled: true
  size: 1Gi

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: adguard.example.com
      paths:
        - path: /
          pathType: Prefix

resources:
  requests:
    cpu: 50m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi
EOF
```

### Vaultwarden (密码管理)

```bash
helm install vault sakullla/vaultwarden -f - <<EOF
persistence:
  enabled: true
  size: 10Gi
  storageClass: longhorn

ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  hosts:
    - host: vault.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: vault-tls
      hosts:
        - vault.example.com

secrets:
  ADMIN_TOKEN: "your-admin-token"
  SMTP_HOST: "smtp.gmail.com"
  SMTP_FROM: "vault@example.com"
  SMTP_USERNAME: "user@gmail.com"
  SMTP_PASSWORD: "app-password"

resources:
  requests:
    cpu: 50m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi
EOF
```

### Lobe Chat (AI 聊天)

```bash
helm install chat sakullla/lobehub -f - <<EOF
httpRoute:
  enabled: true
  parentRefs:
    - name: traefik-gateway
      namespace: kube-system
  hostnames:
    - chat.example.com

env:
  APP_URL: "https://chat.example.com"
  NEXT_PUBLIC_BASE_PATH: ""

secrets:
  DATABASE_URL: "postgresql://lobehub:pass@postgres:5432/lobehub"
  OPENAI_API_KEY: "sk-xxxxxxxxxxxxxxxx"
  OPENAI_PROXY_URL: "https://api.openai.com/v1"

resources:
  requests:
    cpu: 100m
    memory: 256Mi
  limits:
    cpu: 1000m
    memory: 1Gi
EOF
```

### Firecrawl (网页爬虫)

```bash
helm install firecrawl sakullla/firecrawl -f - <<EOF
env:
  REDIS_URL: "redis://valkey.default:6379"
  PLAYWRIGHT_SERVICE_URL: "http://firecrawl-playwright-service:3000"

secrets:
  DATABASE_URL: "postgresql://firecrawl:pass@postgres:5432/firecrawl"
  API_KEY: "fc-your-api-key"

# 启用内置的 Playwright 服务
playwright-service:
  enabled: true

# 如果使用外部 PostgreSQL，可以禁用内置的
nuqPostgres:
  enabled: false

resources:
  requests:
    cpu: 100m
    memory: 256Mi
  limits:
    cpu: 1000m
    memory: 1Gi

# Worker 配置
worker:
  replicaCount: 2
  resources:
    requests:
      cpu: 200m
      memory: 512Mi
    limits:
      cpu: 2000m
      memory: 2Gi
EOF
```

### SearXNG (搜索引擎)

```bash
helm install search sakullla/searxng -f - <<EOF
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: search.example.com
      paths:
        - path: /
          pathType: Prefix

env:
  BASE_URL: "https://search.example.com"
  INSTANCE_NAME: "My Search"

resources:
  requests:
    cpu: 50m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi
EOF
```

### qBittorrent (BT 客户端)

```bash
helm install qb sakullla/qbittorrent -f - <<EOF
persistence:
  enabled: true
  size: 100Gi
  storageClass: longhorn

env:
  WEBUI_PORT: "8080"
  PUID: "1000"
  PGID: "1000"
  TZ: "Asia/Shanghai"

service:
  type: LoadBalancer  # 或使用 Ingress

resources:
  requests:
    cpu: 100m
    memory: 256Mi
  limits:
    cpu: 2000m
    memory: 2Gi
EOF
```

### DDNS-GO (动态 DNS)

```bash
helm install ddns sakullla/ddns-go -f - <<EOF
persistence:
  enabled: true
  size: 500Mi

httpRoute:
  enabled: true
  parentRefs:
    - name: gateway
  hostnames:
    - ddns.example.com

resources:
  requests:
    cpu: 10m
    memory: 50Mi
  limits:
    cpu: 100m
    memory: 128Mi
EOF
```

### Headscale (VPN 控制器)

```bash
helm install vpn sakullla/headscale -f - <<EOF
persistence:
  enabled: true
  size: 1Gi

env:
  SERVER_URL: "https://vpn.example.com"
  LISTEN_ADDR: "0.0.0.0:8080"

secrets:
  NOISE_PRIVATE_KEY: "your-noise-key"
  PRIVATE_KEY: "your-private-key"

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: vpn.example.com
      paths:
        - path: /
          pathType: Prefix

resources:
  requests:
    cpu: 50m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi
EOF
```

### Kavita (电子书阅读)

```bash
helm install books sakullla/kavita -f - <<EOF
persistence:
  enabled: true
  size: 50Gi  # 根据书库大小调整

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: books.example.com
      paths:
        - path: /
          pathType: Prefix

resources:
  requests:
    cpu: 100m
    memory: 256Mi
  limits:
    cpu: 1000m
    memory: 1Gi
EOF
```

### NewAPI (API 网关)

```bash
helm install api sakullla/newapi -f - <<EOF
httpRoute:
  enabled: true
  parentRefs:
    - name: gateway
  hostnames:
    - api.example.com

env:
  REDIS_HOST: "valkey.default"
  REDIS_PORT: "6379"

secrets:
  DATABASE_URL: "postgresql://newapi:pass@postgres:5432/newapi"
  REDIS_PASSWORD: "redis-password"
  SESSION_SECRET: "random-session-secret"
  JWT_SECRET: "random-jwt-secret"

persistence:
  enabled: true
  size: 5Gi

resources:
  requests:
    cpu: 100m
    memory: 256Mi
  limits:
    cpu: 1000m
    memory: 1Gi
EOF
```

## 高级配置

### 使用 Values 文件

创建 `my-values.yaml`：

```yaml
image:
  tag: "v1.2.3"

persistence:
  enabled: true
  size: 10Gi

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: app.example.com
      paths:
        - path: /
          pathType: Prefix

resources:
  requests:
    cpu: 100m
    memory: 256Mi
  limits:
    cpu: 500m
    memory: 512Mi
```

安装：

```bash
helm install my-app sakullla/<chart-name> -f my-values.yaml
```

### 查看配置选项

```bash
# 查看 Chart 的所有可配置参数
helm show values sakullla/<chart-name>

# 查看 Chart 信息
helm show chart sakullla/<chart-name>
```

### 升级和管理

```bash
# 升级应用
helm upgrade my-app sakullla/<chart-name> -f my-values.yaml

# 查看历史版本
helm history my-app

# 回滚
helm rollback my-app 1

# 卸载
helm uninstall my-app
```

## 资源建议

| 应用类型 | CPU 请求 | 内存请求 | CPU 限制 | 内存限制 |
|---------|----------|----------|----------|----------|
| 轻量工具 (DDNS-GO, Certimate) | 10m | 50Mi | 100m | 128Mi |
| 常规应用 (AdGuard, Vaultwarden) | 50m | 128Mi | 500m | 512Mi |
| AI 应用 (Lobehub, NewAPI) | 100m | 256Mi | 1000m | 1Gi |
| 浏览器服务 (Browserless, Playwright) | 200m | 512Mi | 2000m | 2Gi |
| 媒体服务 (qBittorrent, Kavita) | 100m | 256Mi | 2000m | 2Gi |

## 存储建议

| 应用 | 推荐大小 | 说明 |
|-----|---------|------|
| AdGuard Home | 1Gi | 配置和日志 |
| Vaultwarden | 5-10Gi | 密码库和附件 |
| qBittorrent | 100Gi+ | 下载目录 |
| Kavita | 50Gi+ | 根据书库大小 |
| Lobehub | 5Gi | 聊天记录和配置 |
| DDNS-GO | 500Mi | 配置文件 |
| Headscale | 1Gi | 数据库 |

## 常见问题

### 如何持久化数据？

```yaml
persistence:
  enabled: true
  size: 10Gi
  storageClass: "your-storage-class"  # 留空使用默认
```

### 如何配置域名访问？

使用 Ingress：
```yaml
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: app.example.com
      paths:
        - path: /
          pathType: Prefix
```

或使用 Gateway API：
```yaml
httpRoute:
  enabled: true
  parentRefs:
    - name: gateway
      namespace: kube-system
  hostnames:
    - app.example.com
```

### 如何配置环境变量？

普通变量：
```yaml
env:
  TZ: "Asia/Shanghai"
  LOG_LEVEL: "info"
```

敏感信息：
```yaml
secrets:
  DATABASE_URL: "postgresql://..."
  API_KEY: "secret-key"
```

### 如何限制资源使用？

```yaml
resources:
  requests:
    cpu: 100m
    memory: 256Mi
  limits:
    cpu: 1000m
    memory: 1Gi
```

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

[GNU General Public License v3.0](LICENSE)
