# Helm Charts 仓库

[![Release Charts](https://github.com/sakullla/helm-charts/actions/workflows/release.yml/badge.svg)](https://github.com/sakullla/helm-charts/actions/workflows/release.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)

精选的 Kubernetes Helm Charts 集合，包含 35+ 种自托管应用。

## 快速开始

```bash
# 添加仓库
helm repo add sakullla https://sakullla.github.io/helm-charts
helm repo update

# 搜索可用的 Charts
helm search repo sakullla

# 安装应用
helm install my-app sakullla/<chart-name>

# 查看配置选项
helm show values sakullla/<chart-name>
```

## 可用 Charts

| 类别 | 应用 |
|------|------|
| **基础设施与网络** | adguard-home, ddns-go, dns-server, frp, headscale, headplane, nginx-stream, xray, substore |
| **AI 与语言模型** | lobehub, litellm, newapi, next-ai-draw-io |
| **开发工具** | firecrawl, hubproxy, hugo-site, playwright-service |
| **知识管理** | affine, hedgedoc, chartdb |
| **媒体娱乐** | kavita, qbittorrent, calibre-web-automated, ani-rss, yamtrack, misaka-danmu-server |
| **安全与认证** | vaultwarden, certimate |
| **搜索与隐私** | searxng |
| **机器人与自动化** | astrbot, saveany-bot, quote-bot, quote-api, koipy |
| **其他工具** | taskflow, tabby-web, logvar, miaospeed, openlist |

## 通用配置

所有 Charts 支持以下核心配置项：

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
  storageClass: "longhorn"
  accessMode: ReadWriteOnce

# 环境变量
env:
  TZ: "Asia/Shanghai"
  LOG_LEVEL: "info"

# 敏感信息（Secret）
secrets:
  DATABASE_URL: "postgresql://user:pass@host:5432/db"
  API_KEY: "your-secret-key"
```

## 网络访问

### Ingress（推荐）
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

### Gateway API HTTPRoute
```yaml
httpRoute:
  enabled: true
  parentRefs:
    - name: gateway
      namespace: kube-system
  hostnames:
    - app.example.com
```

### NodePort / LoadBalancer
```yaml
service:
  type: NodePort
  port: 80
```

## 常用应用配置示例

### AdGuard Home（广告拦截）
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
EOF
```

### Vaultwarden（密码管理）
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
EOF
```

### Lobe Chat（AI 聊天）
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

secrets:
  DATABASE_URL: "postgresql://lobehub:pass@postgres:5432/lobehub"
  OPENAI_API_KEY: "sk-xxxxxxxxxxxxxxxx"
EOF
```

### qBittorrent（BT 客户端）
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
  type: LoadBalancer
EOF
```

## 资源建议

| 应用类型 | CPU 请求 | 内存请求 | CPU 限制 | 内存限制 |
|---------|----------|----------|----------|----------|
| 轻量工具 | 10m | 50Mi | 100m | 128Mi |
| 常规应用 | 50m | 128Mi | 500m | 512Mi |
| AI 应用 | 100m | 256Mi | 1000m | 1Gi |
| 浏览器服务 | 200m | 512Mi | 2000m | 2Gi |
| 媒体服务 | 100m | 256Mi | 2000m | 2Gi |

## 高级操作

```bash
# 使用 Values 文件安装
helm install my-app sakullla/<chart-name> -f my-values.yaml

# 升级应用
helm upgrade my-app sakullla/<chart-name> -f my-values.yaml

# 查看历史版本
helm history my-app

# 回滚
helm rollback my-app 1

# 卸载
helm uninstall my-app
```

## 许可证

[GNU General Public License v3.0](LICENSE)
