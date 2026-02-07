# Helm Charts 仓库

[![Release Charts](https://github.com/sakullla/helm-charts/actions/workflows/release.yml/badge.svg)](https://github.com/sakullla/helm-charts/actions/workflows/release.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)

这是一个用于 Kubernetes 的 Helm Charts 仓库，包含各种自托管应用的 Helm Charts。

## 目录

- [简介](#简介)
- [快速开始](#快速开始)
- [可用 Charts](#可用-charts)
- [使用方法](#使用方法)
- [配置](#配置)
- [开发](#开发)
- [许可证](#许可证)

## 简介

本仓库提供了一系列精心配置的 Helm Charts，帮助您在 Kubernetes 集群上快速部署各种自托管应用。所有 Charts 都遵循 Helm 最佳实践，并支持多种配置选项。

## 快速开始

### 前提条件

- Kubernetes 1.20+
- Helm 3.8.0+

### 添加仓库

```bash
helm repo add sakullla https://sakullla.github.io/helm-charts
helm repo update
```

### 安装 Chart

```bash
# 安装 AdGuard Home
helm install my-adguard-home sakullla/adguard-home

# 查看所有可用的 charts
helm search repo sakullla
```

## 可用 Charts

| Chart | 描述 | 版本 |
|-------|------|------|
| [adguard-home](charts/adguard-home) | 网络级广告和跟踪器拦截 DNS 服务器 | 0.1.8 |
| [affine](charts/affine) | 下一代知识库管理工具 | 0.0.1 |
| [ani-rss](charts/ani-rss) | 动漫 RSS 自动下载工具 | - |
| [astrbot](charts/astrbot) | 多平台聊天机器人框架 | - |
| [browserless-chromium](charts/browserless-chromium) | 无头 Chrome/Chromium 浏览器服务 | - |
| [calibre-web-automated](charts/calibre-web-automated) | Calibre 电子书管理 Web 界面 | - |
| [certimate](charts/certimate) | SSL 证书自动化管理工具 | - |
| [chartdb](charts/chartdb) | 数据库图表可视化工具 | - |
| [ddns-go](charts/ddns-go) | 自动 DDNS 工具 | - |
| [dns-server](charts/dns-server) | DNS 服务器 | - |
| [firecrawl](charts/firecrawl) | 网站爬虫和数据提取工具 | - |
| [frp](charts/frp) | 快速反向代理 (FRP) | - |
| [headplane](charts/headplane) | Headscale Web UI | - |
| [headscale](charts/headscale) | Tailscale 控制服务器 | - |
| [hedgedoc](charts/hedgedoc) | 实时协作文档编辑器 | - |
| [hedgedoc-backend](charts/hedgedoc-backend) | HedgeDoc 后端服务 | - |
| [hubproxy](charts/hubproxy) | Docker Hub 代理 | - |
| [hugo-site](charts/hugo-site) | Hugo 静态网站生成器 | - |
| [kavita](charts/kavita) | 电子书、漫画和 PDF 阅读器 | - |
| [kirara-agent](charts/kirara-agent) | Kirara AI Agent | - |
| [koipy](charts/koipy) | 代理工具 | - |
| [lobehub](charts/lobehub) | Lobe Chat AI 聊天界面 | - |
| [logvar](charts/logvar) | 日志变量收集工具 | - |
| [miaospeed](charts/miaospeed) | 网络速度测试工具 | - |
| [misaka-danmu-server](charts/misaka-danmu-server) | 弹幕服务器 | - |
| [misub](charts/misub) | 订阅管理工具 | - |
| [newapi](charts/newapi) | API 管理工具 | - |
| [next-ai-draw-io](charts/next-ai-draw-io) | AI 绘图工具 | - |
| [openlist](charts/openlist) | 开源列表管理 | - |
| [oplist-api](charts/oplist-api) | OpenList API 服务 | - |
| [playwright-service](charts/playwright-service) | Playwright 自动化测试服务 | - |
| [qbittorrent](charts/qbittorrent) | BitTorrent 客户端 | - |
| [saveany-bot](charts/saveany-bot) | 内容保存机器人 | - |
| [searxng](charts/searxng) | 隐私保护的元搜索引擎 | - |
| [substore](charts/substore) | 订阅转换工具 | - |
| [tabby-web](charts/tabby-web) | Tabby 终端 Web 版本 | - |
| [vaultwarden](charts/vaultwarden) | Bitwarden 兼容的密码管理器 | - |
| [xray](charts/xray) | Xray 代理工具 | - |
| [yamtrack](charts/yamtrack) | 媒体追踪工具 | - |

## 使用方法

### 基本安装

```bash
# 使用默认配置安装
helm install <release-name> sakullla/<chart-name>

# 示例：安装 Vaultwarden
helm install my-vaultwarden sakullla/vaultwarden
```

### 自定义配置

```bash
# 使用自定义 values 文件安装
helm install <release-name> sakullla/<chart-name> -f my-values.yaml

# 使用命令行参数覆盖配置
helm install <release-name> sakullla/<chart-name> \
  --set persistence.enabled=true \
  --set persistence.size=10Gi
```

### 查看可用配置选项

```bash
# 查看 Chart 的所有可配置参数
helm show values sakullla/<chart-name>
```

### 升级和卸载

```bash
# 升级 Release
helm upgrade <release-name> sakullla/<chart-name>

# 卸载 Release
helm uninstall <release-name>
```

## 配置

### 通用配置选项

所有 Charts 都支持以下通用配置：

| 参数 | 描述 | 默认值 |
|------|------|--------|
| `replicaCount` | Pod 副本数 | `1` |
| `image.repository` | 镜像仓库 | 应用特定 |
| `image.tag` | 镜像标签 | ` "" ` (默认使用 appVersion) |
| `image.pullPolicy` | 镜像拉取策略 | `IfNotPresent` |
| `service.type` | 服务类型 | `ClusterIP` |
| `service.port` | 服务端口 | 应用特定 |
| `ingress.enabled` | 启用 Ingress | `false` |
| `ingress.className` | Ingress 类名 | `""` |
| `ingress.hosts` | Ingress 主机配置 | `[]` |
| `ingress.tls` | Ingress TLS 配置 | `[]` |
| `httpRoute.enabled` | 启用 Gateway API HTTPRoute | `false` |
| `persistence.enabled` | 启用持久化存储 | `false` |
| `persistence.size` | 存储大小 | `1Gi` |
| `persistence.storageClass` | 存储类 | `""` |
| `resources` | 资源限制和请求 | `{}` |
| `nodeSelector` | 节点选择器 | `{}` |
| `tolerations` | 容忍配置 | `[]` |
| `affinity` | 亲和性配置 | `{}` |
| `autoscaling.enabled` | 启用 HPA | `false` |

### 网络访问方式

本仓库的 Charts 支持多种网络访问方式：

#### 1. Ingress（推荐用于生产环境）

```yaml
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: adguard.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: adguard-tls
      hosts:
        - adguard.example.com
```

#### 2. Gateway API HTTPRoute

```yaml
httpRoute:
  enabled: true
  parentRefs:
    - name: gateway
      sectionName: http
  hostnames:
    - adguard.example.com
```

#### 3. LoadBalancer

```yaml
service:
  type: LoadBalancer
```

#### 4. NodePort

```yaml
service:
  type: NodePort
```

#### 5. Port Forward（仅用于测试）

```bash
kubectl port-forward svc/<release-name> 8080:3000
```

### 持久化存储

大多数应用支持持久化存储来保存数据：

```yaml
persistence:
  enabled: true
  size: 10Gi
  storageClass: standard  # 可选，使用默认存储类则留空
  accessMode: ReadWriteOnce
```

## 开发

### 本地测试

```bash
# 克隆仓库
git clone https://github.com/sakullla/helm-charts.git
cd helm-charts

# 渲染模板（用于测试）
helm template <chart-name> charts/<chart-name>

# 在本地 Kubernetes 集群测试安装
helm install <release-name> charts/<chart-name> --dry-run

# 使用 Kind 或 Minikube 进行实际测试
helm install <release-name> charts/<chart-name>
```

### 添加新 Chart

1. 使用 Helm 创建新 Chart：
```bash
helm create charts/<new-chart-name>
```

2. 编辑 `Chart.yaml` 和 `values.yaml` 配置

3. 在 `templates/` 目录中添加 Kubernetes 资源模板

4. 提交并推送更改，CI 将自动发布新版本

### CI/CD 流程

本仓库使用 GitHub Actions 自动发布 Charts：

- 每次推送到 `main` 分支且修改了 `charts/` 目录时触发
- 自动打包并发布 Chart 到 GitHub Pages
- 自动清理旧版本，只保留最新版本

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

本项目采用 [GNU General Public License v3.0](LICENSE) 许可证。

## 致谢

感谢所有为本项目做出贡献的开发者。
